import 'dart:async';

import 'package:async/async.dart';
import 'package:cancellable_process/cancellable_process.dart';
import 'package:either_dart/either.dart';

class CancellableProcess<T, K> {
  /// [timeout] Specifies the timeout period of the given function.
  Duration timeout;

  /// [fn] The function you want to run.
  Future<T> Function()? fn;

  /// [retryReason] Indicates situations that require retrying of the given function
  bool Function(T)? retryReason;

  /// [maxAttempts] Specifies the maximum number of attempts.
  int maxAttempts;

  /// [delay] Specifies delays between retries.
  Duration? delay;

  int _currentAttempt = 0;

  CancelableCompleter<AppResult<T>>? _completer;

  /// [CancellableProcess] For functions without parameters.
  CancellableProcess({
    this.fn,
    required this.timeout,
    required this.retryReason,
    required this.maxAttempts,
  });

  /// [CancellableProcess.withArgs] For functions with parameters.
  factory CancellableProcess.withArgs({
    required Future<T> Function(K) function,
    required timeout,
    required retryReason,
    required maxAttempts,
    required dynamic arg,
  }) {
    return _CancellableProcessWithArgs(
      maxAttempts: maxAttempts,
      retryReason: retryReason,
      timeout: timeout,
      fnWithArgs: function,
      arg: arg,
    );
  }

  /// [run] Runs the process you describe.
  Future<AppResult<T>> run() async {
    _completer ??= CancelableCompleter<AppResult<T>>();
    if (fn == null) {
      throw "fn should be use!";
    }
    await fn!().then((value) async {
      _currentAttempt++;
      if (retryReason != null) {
        if (retryReason!(value)) {
          if (_currentAttempt < maxAttempts) {
            if (delay != null) await Future.delayed(delay!);
            await run();
          } else {
            _currentAttempt = 0;
            if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
              _completer?.complete(Left(ProcessError(ProcessErrorType.maxAttempts, errorMsg: "Max Attempts Error")));
            }
          }
        } else {
          _currentAttempt = 0;
          if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
            _completer?.complete(Right(value));
          }
        }
      } else {
        _currentAttempt = 0;
        if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
          _completer?.complete(Right(value));
        }
      }
    }).catchError((e, s) async {
      _currentAttempt++;
      if (_currentAttempt < maxAttempts) {
        if (delay != null) await Future.delayed(delay!);
        await run();
      } else {
        _currentAttempt = 0;
        if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
          _completer?.complete(Left(ProcessError(ProcessErrorType.catchError, errorMsg: e.toString())));
        }
      }
    }).timeout(
      timeout,
      onTimeout: () async {
        _currentAttempt++;
        if (_currentAttempt < maxAttempts) {
          if (delay != null) await Future.delayed(delay!);
          await run();
        } else {
          _currentAttempt = 0;
          if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
            _completer?.complete(Left(ProcessError(ProcessErrorType.timeout, errorMsg: "Timeout Error")));
          }
        }
      },
    );
    return _completer!.operation.value;
  }

  Future<void> cancel() async {
    _completer?.operation.cancel();
  }
}

class _CancellableProcessWithArgs<T, K> extends CancellableProcess<T, K> {
  _CancellableProcessWithArgs({
    required super.timeout,
    required super.retryReason,
    required super.maxAttempts,
    required this.fnWithArgs,
    required this.arg,
  });
  Future<T> Function(K)? fnWithArgs;
  dynamic arg;
  @override
  Future<AppResult<T>> run() async {
    _completer ??= CancelableCompleter<AppResult<T>>();
    if (fnWithArgs == null) {
      throw "fn should be use!";
    }
    await fnWithArgs!(arg).then((value) async {
      _currentAttempt++;
      if (retryReason != null) {
        if (retryReason!(value)) {
          if (_currentAttempt < maxAttempts) {
            if (delay != null) await Future.delayed(delay!);
            await run();
          } else {
            _currentAttempt = 0;
            if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
              _completer?.complete(Left(ProcessError(ProcessErrorType.maxAttempts, errorMsg: "Max Attempts Error")));
            }
          }
        } else {
          _currentAttempt = 0;
          if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
            _completer?.complete(Right(value));
          }
        }
      } else {
        _currentAttempt = 0;
        if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
          _completer?.complete(Right(value));
        }
      }
    }).catchError((e, s) async {
      _currentAttempt++;
      if (_currentAttempt < maxAttempts) {
        if (delay != null) await Future.delayed(delay!);
        await run();
      } else {
        _currentAttempt = 0;
        if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
          _completer?.complete(Left(ProcessError(ProcessErrorType.catchError, errorMsg: e.toString())));
        }
      }
    }).timeout(
      timeout,
      onTimeout: () async {
        _currentAttempt++;
        if (_currentAttempt < maxAttempts) {
          if (delay != null) await Future.delayed(delay!);
          await run();
        } else {
          _currentAttempt = 0;
          if (!(_completer?.isCanceled ?? true) && !(_completer?.isCompleted ?? true)) {
            _completer?.complete(Left(ProcessError(ProcessErrorType.timeout, errorMsg: "Timeout Error")));
          }
        }
      },
    );
    return _completer!.operation.value;
  }
}
