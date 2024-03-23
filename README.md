## About

Provides an easy way to retry asynchronous functions. The delay and asynchronous functions you will give are repeated according to the maximum number of repetitions you will give, and the answer is returned as an error or correct result. Error handling is provided using the Either package.

**[⚠ Dependency Warning]()**

Either: https://pub.dev/packages/either_dart
Async: https://pub.dev/packages/async

## Usage/Example

```dart
//With Arguments Function Example
void main() {
  Future<int> randomNumber(int max) async {
    await Future.delayed(const Duration(seconds: 2));
    return Random().nextInt(max);
  }

  var cancellable = CancellableProcess<int>(
    function: () => randomNumber(20),
    timeout: const Duration(seconds: 5),
    retryReason: (val) => val == 3,
    maxAttempts: 2,
  );

  var handler = await cancellable.run();

  if (handler.isLeft) {
    print(handler.left.errorMsg);
  } else {
    print(handler.right);
  }
}

//Without Arguments Function Example
void main() {
  Future<int> randomNumber() async {
    await Future.delayed(const Duration(seconds: 2));
    return Random().nextInt(20);
  }

  var cancellable = CancellableProcess<int>(
    function: randomNumber,
    timeout: const Duration(seconds: 5),
    retryReason: (val) => val == 3,
    maxAttempts: 10,
  );

  var handler = await cancellable.run();

  if (handler.isLeft) {
    print(handler.left.errorMsg);
  } else {
    print(handler.right);
  }
}
// Future Cancel Example
void main() {
  Future<int> randomNumber(int max) async {
    await Future.delayed(const Duration(seconds: 6));
    return Random().nextInt(max);
  }

  var cancellable = CancellableProcess<int>(
    function: () => randomNumber(20),
    timeout: const Duration(seconds: 10),
    retryReason: (val) => val == 99,
    maxAttempts: 2,
  );
  cancellable.run();
  print("Cancellable Run");
  await Future.delayed(const Duration(seconds: 1),() {
    print("Cancel Start");
    cancellable.cancel();
   },
 );
}

```

You can find different examples in the test file of the project.

## Feedback

If you have any feedback, please contact us at erndemir.1@gmail.com.
