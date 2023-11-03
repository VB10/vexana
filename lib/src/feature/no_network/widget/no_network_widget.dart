part of '../no_network_manager.dart';
class _NoNetworkWidget extends StatelessWidget {
  const _NoNetworkWidget({
    required String lottiePath,
    required String packageName,
    required this.onRetry,
  })  : _lottiePath = lottiePath,
        _packageName = packageName;

  final String _lottiePath;
  final String _packageName;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: LottieBuilder.asset(_lottiePath, package: _packageName),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
