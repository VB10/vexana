import 'package:flutter/material.dart';

/// NoNetwork model class
final class NoNetwork {
  /// Implement required parameters
  /// [context] is required for show modal bottom sheet
  /// [customNoNetwork] is optional for want to make custom no network widget
  NoNetwork(this.context, {this.customNoNetwork});

  /// BuildContext for show modal bottom sheet
  final BuildContext context;

  /// Define your custom no network widget
  final Widget Function(void Function()? onRetry)? customNoNetwork;
}
