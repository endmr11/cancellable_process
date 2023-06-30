import 'package:either_dart/either.dart';

enum ProcessErrorType {
  catchError,
  undefined,
  timeout,
  maxAttempts,
}

class ProcessError {
  final ProcessErrorType error;
  final String errorMsg;
  ProcessError(this.error, {required this.errorMsg});
}

typedef AppResult<T> = Either<ProcessError, T>;
