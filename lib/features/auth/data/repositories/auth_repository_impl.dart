import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:woocommerce_app/core/error/exceptions.dart';
import 'package:woocommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:woocommerce_app/features/auth/data/models/login_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/login_response_model.dart';
import 'package:woocommerce_app/features/auth/data/models/signup_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:woocommerce_app/features/auth/domain/entities/user.dart';
import 'package:woocommerce_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<User> login(LoginRequestModel request) async {
    try {
      final response = await remoteDataSource.login(request);
      await _cacheAuthData(response);
      return response.user;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      // First try to get the user from the remote data source
      final userData = await remoteDataSource.getCurrentUser();
      final token = await secureStorage.read(key: _tokenKey);
      
      // Create user from remote data
      final user = User(
        id: userData['id'],
        email: userData['email'] ?? '',
        username: userData['username'],
        firstName: userData['first_name'],
        lastName: userData['last_name'],
        displayName: userData['name'],
        avatarUrl: userData['avatar_urls']?['96'],
        token: token,
        isAdmin: userData['roles']?.contains('administrator') ?? false,
      );
      
      // Update the stored user data
      await secureStorage.write(
        key: _userKey,
        value: user.email,
      );
      
      return user;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw const ServerException(message: 'Failed to get user data');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Future.wait([
        secureStorage.delete(key: _tokenKey),
        secureStorage.delete(key: _userKey),
      ]);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await secureStorage.read(key: _tokenKey);
      final userEmail = await secureStorage.read(key: _userKey);
      
      // Check if both token and user data exist
      final isAuthenticated = token != null && 
                            token.isNotEmpty && 
                            userEmail != null && 
                            userEmail.isNotEmpty;
      
      // If we think we're authenticated, verify with the server
      if (isAuthenticated) {
        try {
          // This will throw an exception if the token is invalid
          await remoteDataSource.getCurrentUser();
          return true;
        } catch (e) {
          // If we can't get the current user, we're not authenticated
          await logout();
          return false;
        }
      }
      
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User> signup(SignupRequestModel request) async {
    try {
      final response = await remoteDataSource.signup(request);
      await _cacheAuthData(response);
      return response.user;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      await remoteDataSource.resetPassword(request);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  Future<void> _cacheAuthData(LoginResponseModel response) async {
    try {
      // Store token
      await secureStorage.write(
        key: _tokenKey,
        value: response.token,
      );
      
      // Store user data
      await secureStorage.write(
        key: _userKey,
        value: response.user.email, // Store email as user identifier
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw const CacheException();
    }
  }
}
