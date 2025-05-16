import 'package:woocommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:woocommerce_app/features/auth/data/models/signup_request_model.dart';
import 'package:woocommerce_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:woocommerce_app/features/auth/domain/entities/user.dart';

/// Use case for user signup
/// 
/// Takes a [SignupRequestModel] and returns either a [User] or a [Failure]
abstract class Signup {
  Future<Either<Failure, User>> call(SignupRequestModel request);
}

class SignupImpl implements Signup {
  final AuthRepository repository;

  SignupImpl(this.repository);

  @override
  Future<Either<Failure, User>> call(SignupRequestModel request) async {
    try {
      final user = await repository.signup(request);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
