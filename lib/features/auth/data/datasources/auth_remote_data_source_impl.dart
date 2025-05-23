import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:woocommerce_app/core/error/exceptions.dart';
import 'package:woocommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:woocommerce_app/features/auth/data/models/login_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/login_response_model.dart';
import 'package:woocommerce_app/features/auth/data/models/signup_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/reset_password_request_model.dart';

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String jwtBaseUrl;
  final String consumerKey;
  final String consumerSecret;
  final FlutterSecureStorage secureStorage;
  static const String _tokenKey = 'auth_token';
  
  // Endpoints
  static const String _loginEndpoint = '/token';
  static const String _userEndpoint = '/wp-json/wc/v3/customers/me';

  AuthRemoteDataSourceImpl({
    required this.client,
    required String baseUrl,
    required this.consumerKey,
    required this.consumerSecret,
    required this.secureStorage,
    required String jwtBaseUrl,
  }) : baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
       jwtBaseUrl = jwtBaseUrl.endsWith('/') ? jwtBaseUrl : '$jwtBaseUrl/';

  // Add basic authentication headers for WooCommerce REST API
  Map<String, String> get _wooAuthHeaders {
    final credentials = '$consumerKey:$consumerSecret';
    final base64Credentials = base64Encode(utf8.encode(credentials));
    return {
      'Authorization': 'Basic $base64Credentials',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final url = Uri.parse('$jwtBaseUrl$_loginEndpoint');
    
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return LoginResponseModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw ServerException(
          message: errorData['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on FormatException {
      throw const ServerException(message: 'Invalid response from server');
    } catch (e) {
      throw ServerException(message: 'Failed to connect to the server: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await secureStorage.read(key: _tokenKey);
    if (token == null) {
      throw const ServerException(message: 'No authentication token found');
    }

    final url = Uri.parse('$baseUrl$_userEndpoint');
    
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        throw ServerException(
          message: errorBody['message'] ?? 'Failed to fetch user data',
          statusCode: response.statusCode,
        );
      }
    } on FormatException {
      throw const ServerException(message: 'Invalid response from server');
    } catch (e) {
      throw ServerException(message: 'Failed to connect to the server: $e');
    }
  }

  // This method is kept for future use when we need to get the stored token
  @visibleForTesting
  Future<String> getStoredToken() async {
    final token = await secureStorage.read(key: _tokenKey);
    if (token == null) {
      throw const ServerException(message: 'No authentication token found');
    }
    return token;
  }

  @override
  Future<LoginResponseModel> signup(SignupRequestModel request) async {
    final signupUrl = Uri.parse('$baseUrl/wp-json/wc/v3/customers');
    
    try {
      // Log the request for debugging
      debugPrint('Signup request: ${request.toJson()}');
      
      // Create the user account
      final signupResponse = await client.post(
        signupUrl,
        headers: _wooAuthHeaders,
        body: jsonEncode({
          'email': request.email,
          'username': request.username,
          'password': request.password,
          'first_name': request.username,
          'last_name': '',
        }),
      ).timeout(const Duration(seconds: 30));

      // Log the response for debugging
      debugPrint('Signup response: ${signupResponse.statusCode} - ${signupResponse.body}');

      if (signupResponse.statusCode == 201) {
        // After successful signup, log the user in using JWT
        debugPrint('User account created successfully, attempting to log in...');
        try {
          final loginResponse = await login(LoginRequestModel(
            username: request.email,
            password: request.password,
          ));
          debugPrint('Auto-login after signup successful');
          return loginResponse;
        } catch (loginError) {
          debugPrint('Auto-login after signup failed: $loginError');
          // Even if auto-login fails, the account was created successfully
          // So we'll throw a more specific error
          throw const ServerException(
            message: 'Account created but failed to log in automatically. Please try logging in manually.',
            statusCode: 200, // Using 200 to indicate partial success
          );
        }
      } else {
        String errorMessage = 'Failed to create user account';
        try {
          final errorBody = jsonDecode(utf8.decode(signupResponse.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
          
          // Handle specific WooCommerce error messages
          if (errorBody['code'] == 'registration-error-email-exists') {
            errorMessage = 'An account is already registered with this email address.';
          } else if (errorBody['code'] == 'registration-error-username-exists') {
            errorMessage = 'Username already exists. Please choose another one.';
          } else if (errorBody['code'] == 'registration-error-invalid-email') {
            errorMessage = 'Please provide a valid email address.';
          } else if (errorBody['code'] == 'registration-error-weak-password') {
            errorMessage = 'Password is too weak. Please choose a stronger password.';
          }
        } catch (e) {
          debugPrint('Error parsing error response: $e');
        }
        
        debugPrint('Signup error (${signupResponse.statusCode}): $errorMessage');
        throw ServerException(
          message: errorMessage,
          statusCode: signupResponse.statusCode,
        );
      }
    } on FormatException {
      throw const ServerException(message: 'Invalid response from server');
    } catch (e) {
      throw ServerException(message: 'Failed to connect to the server: $e');
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    final url = Uri.parse('$jwtBaseUrl/reset-password');
    
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': request.email,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        throw ServerException(
          message: errorBody['message'] ?? 'Failed to reset password',
          statusCode: response.statusCode,
        );
      }
    } on FormatException {
      throw const ServerException(message: 'Invalid response from server');
    } catch (e) {
      throw ServerException(message: 'Failed to connect to the server: $e');
    }
  }
}
