import 'dart:async';

/// Runs a computation synchronously/inline on web platforms without isolates.
Future<R> runCompute<Q, R>(
  FutureOr<R> Function(Q message) callback,
  Q message,
) async {
  return callback(message);
}
