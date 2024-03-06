part of '../no_network_manager.dart';

class _NoNetworkWidget extends StatelessWidget {
  const _NoNetworkWidget({
    required this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Expanded(
            child: CircularProgressIndicator(),
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
