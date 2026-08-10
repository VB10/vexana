import 'package:flutter/material.dart';
import 'package:playground/src/service/session_metrics.dart';
import 'package:playground/src/widget/metric_tile.dart';
import 'package:playground/src/widget/summary_table.dart';

class MetricsPanel extends StatelessWidget {
  const MetricsPanel({
    required this.metrics,
    required this.onClear,
    super.key,
  });

  final SessionMetrics metrics;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final summary = metrics.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(onClear: onClear),
        if (summary.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SummaryTable(summary: summary),
          ),
          const SizedBox(height: 12),
        ],
        const Divider(height: 1),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    if (metrics.isEmpty) {
      return const Center(child: Text('No metrics yet.'));
    }

    final entries = metrics.entries;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => MetricTile(
        metric: entries[index],
        isSlow: metrics.isSlow(entries[index]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            'Session metrics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}
