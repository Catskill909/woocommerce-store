// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// Server exceptions
class ServerException extends AppException {
  const ServerException({String message = 'Server error', int? statusCode})
      : super(message, statusCode: statusCode);
}

// Cache exceptions
class CacheException extends AppException {
  const CacheException({String message = 'Cache error'}) : super(message);
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException({String message = 'Network error'}) : super(message);
}

// Authentication exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException({String message = 'Unauthorized'}) : super(message);
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({String message = 'Validation failed', required this.errors})
      : super(message);
}
