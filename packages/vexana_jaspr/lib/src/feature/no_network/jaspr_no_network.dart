import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:vexana_core/vexana_core.dart';
import 'package:vexana_jaspr/src/feature/network_check/jaspr_network_check.dart';

/// Callback signature for retry action.
typedef JasprRetryCallback = Future<void> Function();

/// Called when a request fails while the browser is offline.
///
/// Call [retry] to resend the request or [dismiss] to give up. The failed
/// request stays pending until one of them is called.
typedef JasprNetworkLossCallback = void Function(
  JasprRetryCallback retry,
  void Function() dismiss,
);

/// Jaspr implementation of [INoNetworkHandler].
///
/// Does nothing while the browser is online, so server errors are returned
/// to the caller instead of being retried.
final class JasprNoNetwork implements INoNetworkHandler {
  /// Creates a [JasprNoNetwork] handler.
  ///
  /// [isOnline] defaults to [JasprNetworkCheck].
  JasprNoNetwork({this.onNetworkLoss, Future<bool> Function()? isOnline})
      : _isOnline = isOnline ?? JasprNetworkCheck.instance.isNetworkAvailable;

  /// Invoked when the browser is offline. Without it no retry happens.
  final JasprNetworkLossCallback? onNetworkLoss;

  final Future<bool> Function() _isOnline;

  @override
  Future<void> handle({
    required Future<void> Function() onRetry,
    String? host,
  }) async {
    final onNetworkLoss = this.onNetworkLoss;
    if (onNetworkLoss == null || await _isOnline()) return;

    final completer = Completer<void>();
    var isSettled = false;
    onNetworkLoss(
      () async {
        if (isSettled) return;
        isSettled = true;
        await onRetry();
        completer.complete();
      },
      () {
        if (isSettled) return;
        isSettled = true;
        completer.complete();
      },
    );
    return completer.future;
  }
}

/// A default Jaspr UI component to display a "No Network" banner with retry.
final class JasprNoNetworkComponent extends StatelessComponent {
  /// Creates a [JasprNoNetworkComponent].
  const JasprNoNetworkComponent({
    required this.onRetry,
    this.message = 'No internet connection.',
    this.buttonText = 'Retry',
    super.key,
  });

  /// Message displayed to the user.
  final String message;

  /// Text on the retry button.
  final String buttonText;

  /// Callback when user clicks the retry button.
  final void Function() onRetry;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'vexana-no-network-banner',
      styles: const Styles(
        display: Display.flex,
        alignItems: AlignItems.center,
        justifyContent: JustifyContent.spaceBetween,
        padding: Padding.all(Unit.pixels(16)),
        backgroundColor: Colors.red,
        color: Colors.white,
      ),
      [
        span([Component.text(message)]),
        button(
          onClick: onRetry,
          styles: const Styles(
            padding: Padding.symmetric(
              vertical: Unit.pixels(8),
              horizontal: Unit.pixels(16),
            ),
            cursor: Cursor.pointer,
          ),
          [Component.text(buttonText)],
        ),
      ],
    );
  }
}
