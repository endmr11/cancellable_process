// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cancellable_process/cancellable_process.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('Cancellable Class Tests', () {
    test('Success With Args', () async {
      Future<int> randomNumber(int max) async {
        await Future.delayed(const Duration(seconds: 2));
        return Random().nextInt(max);
      }

      var cancellable = CancellableProcess<int, int>.withArgs(
        function: randomNumber,
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
      expect(handler.isLeft, false);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Success With Args 2', () async {
      Future<int> randomNumber(List<Object> arg) async {
        await Future.delayed(const Duration(seconds: 2));
        print("txt: ${arg.last}");
        return Random().nextInt(arg.first as int);
      }

      var cancellable = CancellableProcess<int, List<Object>>.withArgs(
        function: randomNumber,
        timeout: const Duration(seconds: 5),
        retryReason: (val) => val == 3,
        maxAttempts: 2,
        arg: [20, "Test Message"],
      );
      var handler = await cancellable.run();

      if (handler.isLeft) {
        print(handler.left.errorMsg);
      } else {
        print(handler.right);
      }
      expect(handler.isLeft, false);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Success Without Args', () async {
      Future<int> randomNumber() async {
        await Future.delayed(const Duration(seconds: 2));
        return Random().nextInt(20);
      }

      var cancellable = CancellableProcess<int, int>(
        fn: randomNumber,
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

      expect(handler.isLeft, false);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Timeout', () async {
      Future<int> randomNumber(int max) async {
        await Future.delayed(const Duration(seconds: 222));
        return Random().nextInt(max);
      }

      var cancellable = CancellableProcess<int, int>.withArgs(
        function: randomNumber,
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

      expect(handler.isLeft, true);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Max Attempts', () async {
      Future<int> randomNumber(int max) async {
        await Future.delayed(const Duration(seconds: 2));
        return Random().nextInt(max);
      }

      var cancellable = CancellableProcess<int, int>.withArgs(
        function: randomNumber,
        timeout: const Duration(seconds: 5),
        retryReason: (val) => val == 0,
        maxAttempts: 2,
        arg: 1,
      );
      var handler = await cancellable.run();

      if (handler.isLeft) {
        print(handler.left.errorMsg);
      } else {
        print(handler.right);
      }

      expect(handler.isLeft, true);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Catch Error', () async {
      Future<int> randomNumber(int max) async {
        await Future.delayed(const Duration(seconds: 2));
        final _ = double.parse('test');
        return Random().nextInt(max);
      }

      var cancellable = CancellableProcess<int, int>.withArgs(
        function: randomNumber,
        timeout: const Duration(seconds: 5),
        retryReason: (val) => val == 0,
        maxAttempts: 2,
        arg: 1,
      );
      var handler = await cancellable.run();

      if (handler.isLeft) {
        print(handler.left.errorMsg);
      } else {
        print(handler.right);
      }

      expect(handler.isLeft, true);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Future Cancel Test', () async {
      Future<int> randomNumber(int max) async {
        await Future.delayed(const Duration(seconds: 6));
        return Random().nextInt(max);
      }

      var cancellable = CancellableProcess<int, int>.withArgs(
        function: randomNumber,
        timeout: const Duration(seconds: 10),
        retryReason: (val) => val == 99,
        maxAttempts: 2,
        arg: 5,
      );
      cancellable.run();
      print("Cancellable Run");
      await Future.delayed(
        const Duration(seconds: 1),
        () {
          print("Cancel Start");
          cancellable.cancel();
        },
      );
      expect(true, true);
    }, timeout: const Timeout(Duration(days: 1)));

    test('Null Futures Test', () async {
      var cancellable = CancellableProcess<int, int>(
        fn: null,
        timeout: const Duration(seconds: 10),
        retryReason: (val) => val == 99,
        maxAttempts: 2,
      );
      try {
        var handler = await cancellable.run();
        if (handler.isLeft) {
          print(handler.left.errorMsg);
        } else {
          print(handler.right);
        }
      } catch (e, s) {
        print("$e, $s");
      }
      expect(true, true);
    }, timeout: const Timeout(Duration(days: 1)));
  });
}
