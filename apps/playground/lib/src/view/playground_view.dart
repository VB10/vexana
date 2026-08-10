import 'package:flutter/material.dart';
import 'package:playground/src/view/playground_view_mixin.dart';
import 'package:playground/src/widget/controls_panel.dart';
import 'package:playground/src/widget/metrics_panel.dart';

class PlaygroundView extends StatefulWidget {
  const PlaygroundView({super.key});

  @override
  State<PlaygroundView> createState() => _PlaygroundViewState();
}

class _PlaygroundViewState extends State<PlaygroundView>
    with PlaygroundViewMixin {
  static const double _wideBreakpoint = 900;
  static const double _controlsWidth = 380;
  static const double _metricsHeightOnNarrow = 520;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('vexana playground'),
        actions: const [_BaseUrlLabel()],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > _wideBreakpoint;
          return isWide ? _buildWide() : _buildNarrow();
        },
      ),
    );
  }

  Widget _buildWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: _controlsWidth, child: _controls),
        const VerticalDivider(width: 1),
        Expanded(child: _metrics),
      ],
    );
  }

  Widget _buildNarrow() {
    return ListView(
      children: [
        _controls,
        const Divider(height: 1),
        SizedBox(height: _metricsHeightOnNarrow, child: _metrics),
      ],
    );
  }

  Widget get _controls => ControlsPanel(
        options: options,
        isBusy: isBusy,
        lastResult: lastResult,
        onOptionsChanged: updateOptions,
        onSend: send,
        onClearCache: clearCache,
      );

  Widget get _metrics => MetricsPanel(
        metrics: metrics,
        onClear: clearMetrics,
      );
}

class _BaseUrlLabel extends StatelessWidget {
  const _BaseUrlLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Text(
          'jsonplaceholder.typicode.com',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
