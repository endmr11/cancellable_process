import 'dart:async';

import 'package:async/async.dart';
import 'package:cancellable_process/cancellable_process.dart';
import 'package:either_dart/either.dart';

class CancellableProcess<T, K> {
  Duration timeout;
  Future<T> Function(K)? fnWithArgs;
  Future<T> Function()? fnWithoutArgs;
  bool Function(T)? retryReason;
  int maxAttempts;
  Duration? delay;
  dynamic arg;
  int currentAttempt = 0;
  CancelableCompleter<AppResult<T>>? completer;
  CancellableProcess({this.fnWithArgs, this.fnWithoutArgs, required this.timeout, required this.retryReason, required this.maxAttempts, this.arg});

  Future<AppResult<T>> run() async {
    completer ??= CancelableCompleter<AppResult<T>>();
    final fn = () {
      if (fnWithArgs != null) {
        return fnWithArgs;
      } else if (fnWithoutArgs != null) {
        return fnWithoutArgs;
      } else if (fnWithArgs != null && fnWithoutArgs != null) {
        throw 'fnWithArgs OR fnWithoutArgs should be use!';
      } else {
        throw 'fnWithArgs OR fnWithoutArgs should be use!';
      }
    }();
    await (arg != null ? fn?.call(arg) : fn?.call()).then((value) async {
      currentAttempt++;
      if (retryReason != null) {
        if (retryReason!(value)) {
          if (currentAttempt < maxAttempts) {
            if (delay != null) await Future.delayed(delay!);
            await run();
          } else {
            currentAttempt = 0;
            if (!(completer?.isCanceled ?? true) && !(completer?.isCompleted ?? true)) {
              completer?.complete(Left(ProcessError(ProcessErrorType.maxAttempts, errorMsg: "Max Attempts Error")));
            }
          }
        } else {
          currentAttempt = 0;
          if (!(completer?.isCanceled ?? true) && !(completer?.isCompleted ?? true)) {
            completer?.complete(Right(value));
          }
        }
      } else {
        currentAttempt = 0;
        if (!(completer?.isCanceled ?? true) && !(completer?.isCompleted ?? true)) {
          completer?.complete(Right(value));
        }
      }
    }).catchError((e, s) async {
      currentAttempt++;
      if (currentAttempt < maxAttempts) {
        if (delay != null) await Future.delayed(delay!);
        await run();
      } else {
        currentAttempt = 0;
        if (!(completer?.isCanceled ?? true) && !(completer?.isCompleted ?? true)) {
          completer?.complete(Left(ProcessError(ProcessErrorType.catchError, errorMsg: e.toString())));
        }
      }
    }).timeout(
      timeout,
      onTimeout: () async {
        currentAttempt++;
        if (currentAttempt < maxAttempts) {
          if (delay != null) await Future.delayed(delay!);
          await run();
        } else {
          currentAttempt = 0;
          if (!(completer?.isCanceled ?? true) && !(completer?.isCompleted ?? true)) {
            completer?.complete(Left(ProcessError(ProcessErrorType.timeout, errorMsg: "Timeout Error")));
          }
        }
      },
    );
    return completer!.operation.value;
  }

  Future<void> cancel() async {
    completer?.operation.cancel();
  }
}
