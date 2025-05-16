import 'package:dartz/dartz.dart';
import 'package:woocommerce_app/core/error/failures.dart';
import 'package:woocommerce_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:woocommerce_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for password reset
/// 
/// Takes a [ResetPasswordRequestModel] and returns either a success or a [Failure]
abstract class ResetPassword {
  Future<Either<Failure, Unit>> call(ResetPasswordRequestModel request);
}

class ResetPasswordImpl implements ResetPassword {
  final AuthRepository repository;

  ResetPasswordImpl(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordRequestModel request) async {
    try {
      await repository.resetPassword(request);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure(message: 'An unexpected error occurred. Please try again.'));
    }
  }
}
