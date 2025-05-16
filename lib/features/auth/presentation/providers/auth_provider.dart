import 'package:flutter/foundation.dart';
import 'package:woocommerce_app/core/error/exceptions.dart';
import 'package:woocommerce_app/features/auth/data/models/login_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/signup_request_model.dart';
import 'package:woocommerce_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:woocommerce_app/features/auth/domain/entities/user.dart';
import 'package:woocommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:woocommerce_app/features/auth/domain/usecases/signup.dart';
import 'package:woocommerce_app/features/auth/domain/usecases/reset_password.dart';
import 'package:dartz/dartz.dart';
import 'package:woocommerce_app/core/error/failures.dart';

class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server error'}) : super(message: message);
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  final Signup _signupUseCase;
  final ResetPassword _resetPasswordUseCase;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepository)
      : _signupUseCase = SignupImpl(_authRepository),
        _resetPasswordUseCase = ResetPasswordImpl(_authRepository);

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user?.token?.isNotEmpty == true;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Check if user is authenticated on app start
  Future<bool> checkAuth() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if we have a valid session
      final isAuth = await _authRepository.isAuthenticated();
      
      if (isAuth) {
        try {
          // Get the latest user data from the server
          _user = await _authRepository.getCurrentUser();
          return true;
        } catch (e) {
          // If we can't get the user data, log out
          await logout();
          _error = 'Session expired. Please log in again.';
          return false;
        }
      }
      
      return false;
    } catch (e) {
      _error = 'Failed to check authentication status. Please try again.';
      debugPrint('AuthProvider.checkAuth error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email/username and password
  Future<bool> login(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        _error = 'Please enter both username and password';
        return false;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _user = await _authRepository.login(
          LoginRequestModel(username: username, password: password),
        );
        
        // Add debug prints to verify the user and token
        debugPrint('User logged in: ${_user?.email}');
        debugPrint('Token: ${_user?.token}');
        
        return true;
      } on ServerException catch (e) {
        _error = e.message;
        debugPrint('ServerException during login: ${e.message}');
        return false;
      } on CacheException {
        _error = 'Failed to save login information. Please try again.';
        debugPrint('CacheException during login');
        return false;
      } catch (e) {
        _error = 'An unexpected error occurred. Please try again.';
        debugPrint('Login error: $e');
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authRepository.logout();
      _user = null;
    } catch (e) {
      _error = 'Failed to log out. Please try again.';
      debugPrint('AuthProvider.logout error: $e');
      // Even if logout fails, we should still clear the local state
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new user
  Future<Either<Failure, User>> signup(SignupRequestModel request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      return await _signupUseCase(request);
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      debugPrint('Signup error: $e');
      return const Left(ServerFailure(message: 'An unexpected error occurred. Please try again.'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request password reset
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      final request = ResetPasswordRequestModel(email: email);
      notifyListeners();

      return await _resetPasswordUseCase(request);
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      debugPrint('Reset password error: $e');
      return const Left(ServerFailure(message: 'An unexpected error occurred. Please try again.'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
