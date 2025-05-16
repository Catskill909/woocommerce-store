import 'package:woocommerce_app/features/auth/data/models/login_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/login_response_model.dart';
import 'package:woocommerce_app/features/auth/data/models/signup_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/reset_password_request_model.dart';

/// Interface for authentication remote data source
abstract class AuthRemoteDataSource {
  /// Authenticates a user with the provided credentials
  /// 
  /// Returns a [LoginResponseModel] containing the JWT token and user data
  /// 
  /// Throws a [ServerException] if authentication fails
  Future<LoginResponseModel> login(LoginRequestModel request);

  /// Retrieves the current authenticated user's data
  /// 
  /// Returns a map containing the user's data
  /// 
  /// Throws a [ServerException] if the request fails
  Future<Map<String, dynamic>> getCurrentUser();

  /// Registers a new user
  /// 
  /// Returns a [LoginResponseModel] containing the JWT token and user data
  /// 
  /// Throws a [ServerException] if registration fails
  Future<LoginResponseModel> signup(SignupRequestModel request);

  /// Requests a password reset
  /// 
  /// Throws a [ServerException] if the request fails
  Future<void> resetPassword(ResetPasswordRequestModel request);
}
