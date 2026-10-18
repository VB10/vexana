import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:vexana_core/vexana_core.dart';

/// Callback signature for retry action.
typedef JasprRetryCallback = Future<void> Function();

/// Jaspr implementation of [INoNetworkHandler].
final class JasprNoNetwork implements INoNetworkHandler {
  /// Creates a [JasprNoNetwork] handler.
  JasprNoNetwork({this.onNetworkLoss});

  /// Custom handler or callback invoked when network is lost.
  final void Function(JasprRetryCallback retry)? onNetworkLoss;

  @override
  Future<void> handle({
    required Future<void> Function() onRetry,
    String? host,
  }) async {
    final completer = Completer<void>();

    Future<void> triggerRetry() async {
      await onRetry();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    if (onNetworkLoss != null) {
      onNetworkLoss!(triggerRetry);
      return completer.future;
    }

    // Default fallback: immediately invoke retry
    return onRetry();
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
