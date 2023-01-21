import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vexana/src/utility/padding/page_padding.dart';
import 'package:vexana/src/utility/widget/border/top_rectangle_border.dart';

class NoNetworkManager {
  final BuildContext? context;
  final void Function()? onRetry;
  final bool isEnable;
  final _lottiePath = 'assets/lottie/lottie_no_network.json';
  final _packageName = 'vexana';
  final Widget Function(void Function()? onRetry)? customNoNetwork;

  NoNetworkManager(
      {required this.context,
      required this.onRetry,
      this.isEnable = false,
      this.customNoNetwork});

  Future<void> show() async {
    if (!isEnable) return;
    if (context == null) return;
    if (await _checkConnectivity()) return;

    await showModalBottomSheet(
      context: context!,
      shape: const TopRectangleBorder(),
      builder: (context) {
        if (customNoNetwork != null) {
          return customNoNetwork!(onRetry);
        }
        return _NoNetworkWidget(
            lottiePath: _lottiePath,
            packageName: _packageName,
            onRetry: onRetry);
      },
    );
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return false;
    return true;
  }
}

abstract class CustomNoNetworkWidget {
  Widget get child;
  Future<void> Function()? onRetry;
}

mixin CustomRetryMixin on StatelessWidget {
  VoidCallback? get onRetry;
}

class ClassName {}

class _NoNetworkWidget extends StatelessWidget with CustomRetryMixin {
  const _NoNetworkWidget({
    Key? key,
    required String lottiePath,
    required String packageName,
    required this.onRetry,
  })  : _lottiePath = lottiePath,
        _packageName = packageName,
        super(key: key);

  final String _lottiePath;
  final String _packageName;
  @override
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: LottieBuilder.asset(_lottiePath, package: _packageName)),
          Padding(
            padding: const PagePadding.horizontal(),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                onRetry?.call();
              },
              child: const Center(
                child: Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
