import 'package:flutter/material.dart';

class CacheWarning extends StatelessWidget {
  const CacheWarning({super.key});

  static const String _message =
      'Known issue (C1): the cache key is baseUrl + HTTP method. Since the '
      'path is not part of the key, GET /posts and GET /posts/1 share the '
      'same cache entry while caching is on.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
