/// An interface to handle network loss scenarios.
///
/// Implemented by UI layers (such as Flutter's `NoNetwork` or Jaspr components)
/// to display a modal or alert and retry the failed request upon user action.
// ignore: one_member_abstracts
abstract interface class INoNetworkHandler {
  /// Handles the network unavailable condition.
  ///
  /// [onRetry] is called if the network becomes available and the user
  /// chooses to retry.
  /// [host] is an optional server hostname (e.g. from `baseUrl`) to target
  /// connectivity checks.
  Future<void> handle({
    required Future<void> Function() onRetry,
    String? host,
  });
}
