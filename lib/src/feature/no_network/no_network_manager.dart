import 'package:flutter/material.dart';
import 'package:vexana/src/feature/network_check/network_check.dart';

part '../no_network/widget/no_network_widget.dart';

/// No network manager
final class NoNetworkManager {
  /// Implement required parameters
  NoNetworkManager({
    required this.context,
    required this.onRetry,
    this.isEnable = false,
    this.customNoNetworkWidget,
  });

  /// BuildContext for show modal bottom sheet
  final BuildContext? context;

  /// When network is not available, this function will be called twice
  final VoidCallback? onRetry;

  /// If you want to show no network modal bottom sheet, you should set true
  final bool isEnable;

  /// Define your custom no network widget
  final Widget Function(VoidCallback? onRetry)? customNoNetworkWidget;

  /// Open no network modal bottom sheet
  Future<void> show() async {
    if (!isEnable) return;
    if (context == null) return;
    if (await _checkConnectivity()) return;

    await showModalBottomSheet<void>(
      context: context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        if (customNoNetworkWidget != null) {
          return customNoNetworkWidget!(onRetry);
        }
        return _NoNetworkWidget(
          onRetry: onRetry,
        );
      },
    );
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await NetworkCheck.instance.isNetworkAvailable();
    return connectivityResult;
  }
}
