import 'package:flutter/material.dart';
import 'package:playground/src/model/request_metric.dart';
import 'package:playground/src/utility/formatters.dart';
import 'package:playground/src/widget/label_chip.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({required this.metric, required this.isSlow, super.key});

  final RequestMetric metric;
  final bool isSlow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: _StatusIcon(metric: metric),
      title: _buildTitle(context),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(spacing: 16, children: _buildTimings()),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            metric.endpoint,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        if (metric.statusCode != null)
          LabelChip(
            label: '${metric.statusCode}',
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        if (metric.fromCache) const LabelChip.cacheHit(),
        if (isSlow) const LabelChip.slow(),
      ],
    );
  }

  List<Widget> _buildTimings() {
    final network = metric.network;
    final parse = metric.parseAndOverhead;
    final bytes = metric.bytes;
    final errorType = metric.errorType;

    return [
      Text('total ${metric.total.readable}'),
      if (network != null) Text('network ${network.readable}'),
      if (parse != null) Text('parse + overhead ${parse.readable}'),
      if (bytes != null) Text(bytes.readableBytes),
      if (errorType != null) Text(errorType),
    ];
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.metric});

  final RequestMetric metric;

  @override
  Widget build(BuildContext context) {
    if (metric.isError) {
      return Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
    if (metric.fromCache) {
      return Icon(Icons.bolt, color: Colors.amber.shade700);
    }
    return Icon(Icons.check_circle_outline, color: Colors.green.shade600);
  }
}
