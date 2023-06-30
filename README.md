## About

Provides an easy way to retry asynchronous functions. The delay and asynchronous functions you will give are repeated according to the maximum number of repetitions you will give, and the answer is returned as an error or correct result. Error handling is provided using the Either package.


**[⚠ Dependency Warning]()**

Either: https://pub.dev/packages/either_dart
Async: https://pub.dev/packages/async

## Usage/Example

```dart

void main() {
  Future<int> randomNumber(int max) async {
    await Future.delayed(const Duration(seconds: 2));
    return Random().nextInt(max);
  }

  var cancellable = CancellableProcess<int, int>(
    fnWithArgs: randomNumber,
    timeout: const Duration(seconds: 5),
    retryReason: (val) => val == 3,
    maxAttempts: 2,
    arg: 20,
  );
  var handler = await cancellable.run();

  if (handler.isLeft) {
    print(handler.left.errorMsg);
  } else {
    print(handler.right);
  }
}

```

You can find different examples in the test file of the project.

## Feedback

If you have any feedback, please contact us at erndemir.1@gmail.com.
