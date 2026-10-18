import 'package:flutter/material.dart';
import 'package:vexana/src/feature/no_network/no_network_manager.dart';
import 'package:vexana_core/vexana_core.dart';

/// NoNetwork model class
final class NoNetwork implements INoNetworkHandler {
  /// Implement required parameters
  /// [context] is required for show modal bottom sheet
  /// [customNoNetwork] is optional for want to make custom no network widget
  NoNetwork(this.context, {this.customNoNetwork});

  /// BuildContext for show modal bottom sheet
  final BuildContext context;

  /// Define your custom no network widget
  final Widget Function(void Function()? onRetry)? customNoNetwork;

  @override
  Future<void> handle({
    required Future<void> Function() onRetry,
    String? host,
  }) async {
    await NoNetworkManager(
      context: context,
      customNoNetworkWidget: customNoNetwork,
      onRetry: () => onRetry(),
      isEnable: true,
      host: host,
    ).show();
  }
}
