import 'package:woocommerce_app/features/auth/data/models/login_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/signup_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:woocommerce_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  // Login with email/username and password
  Future<User> login(LoginRequestModel request);
  
  // Get current user
  Future<User> getCurrentUser();
  
  // Logout
  Future<void> logout();
  
  // Check if user is authenticated
  Future<bool> isAuthenticated();
  
  // Get auth token
  Future<String?> getToken();

  // Register a new user
  Future<User> signup(SignupRequestModel request);

  // Request password reset
  Future<void> resetPassword(ResetPasswordRequestModel request);
}
