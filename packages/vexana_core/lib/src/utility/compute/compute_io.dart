import 'dart:async';
import 'dart:isolate';

/// Runs a computation on a background isolate using [Isolate.run].
Future<R> runCompute<Q, R>(
  FutureOr<R> Function(Q message) callback,
  Q message,
) {
  return Isolate.run(() => callback(message));
}
