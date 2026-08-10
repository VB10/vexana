import 'package:flutter/material.dart';
import 'package:playground/src/model/endpoint.dart';
import 'package:playground/src/model/playground_options.dart';
import 'package:playground/src/widget/cache_warning.dart';

class ControlsPanel extends StatelessWidget {
  const ControlsPanel({
    required this.options,
    required this.isBusy,
    required this.lastResult,
    required this.onOptionsChanged,
    required this.onSend,
    required this.onClearCache,
    super.key,
  });

  final PlaygroundOptions options;
  final bool isBusy;
  final String lastResult;
  final ValueChanged<PlaygroundOptions> onOptionsChanged;
  final VoidCallback onSend;
  final VoidCallback onClearCache;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Request'),
          const SizedBox(height: 12),
          _EndpointField(
            value: options.endpoint,
            onChanged: (endpoint) =>
                onOptionsChanged(options.copyWith(endpoint: endpoint)),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Options'),
          _cacheSwitch,
          if (options.cacheEnabled) _cacheSlider,
          _loggerSwitch,
          const SizedBox(height: 16),
          _actions,
          const SizedBox(height: 16),
          _ResultBox(lastResult),
          if (options.cacheEnabled) ...[
            const SizedBox(height: 16),
            const CacheWarning(),
          ],
        ],
      ),
    );
  }

  Widget get _cacheSwitch => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Cache'),
        subtitle: Text('expiration: ${options.cacheSeconds}s'),
        value: options.cacheEnabled,
        onChanged: (enabled) =>
            onOptionsChanged(options.copyWith(cacheEnabled: enabled)),
      );

  Widget get _cacheSlider => Slider(
        value: options.cacheSeconds.toDouble(),
        min: 5,
        max: 120,
        divisions: 23,
        label: '${options.cacheSeconds}s',
        onChanged: (seconds) =>
            onOptionsChanged(options.copyWith(cacheSeconds: seconds.round())),
      );

  Widget get _loggerSwitch => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Logger'),
        subtitle: const Text('isEnableLogger'),
        value: options.loggerEnabled,
        onChanged: (enabled) =>
            onOptionsChanged(options.copyWith(loggerEnabled: enabled)),
      );

  Widget get _actions => Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: isBusy ? null : onSend,
              icon: isBusy ? const _ButtonSpinner() : const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onClearCache,
            child: const Text('Clear cache'),
          ),
        ],
      );
}

class _EndpointField extends StatelessWidget {
  const _EndpointField({required this.value, required this.onChanged});

  final Endpoint value;
  final ValueChanged<Endpoint> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Endpoint>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Endpoint',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final endpoint in Endpoint.values)
          DropdownMenuItem(value: endpoint, child: Text(endpoint.label)),
      ],
      onChanged: (endpoint) {
        if (endpoint != null) onChanged(endpoint);
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
