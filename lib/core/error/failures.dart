class Failure {
  final String message;

  const Failure({required this.message});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server Failure'}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache Failure'}) : super(message: message);
}
