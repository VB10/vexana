import 'package:flutter/material.dart';
import 'package:playground/src/metrics.dart';
import 'package:playground/src/post.dart';
import 'package:vexana/vexana.dart';

void main() => runApp(const PlaygroundApp());

/// Kullanılabilir demo endpoint'leri.
enum Endpoint {
  posts('GET /posts', '/posts', RequestType.GET, isList: true),
  singlePost('GET /posts/1', '/posts/1', RequestType.GET),
  notFound('GET /nope (404)', '/nope', RequestType.GET),
  createPost('POST /posts', '/posts', RequestType.POST);

  const Endpoint(this.label, this.path, this.method, {this.isList = false});

  final String label;
  final String path;
  final RequestType method;
  final bool isList;
}

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vexana playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3B82F6),
        useMaterial3: true,
      ),
      home: const PlaygroundPage(),
    );
  }
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final _metrics = SessionMetrics();
  final _fileManager = LocalPreferences();

  late NetworkManager<EmptyModel> _manager;

  Endpoint _endpoint = Endpoint.posts;
  bool _cacheEnabled = false;
  bool _loggerEnabled = false;
  int _cacheSeconds = 30;

  bool _busy = false;
  String _lastResult = 'Henüz istek gönderilmedi.';

  /// Interceptor'dan gelen son ağ ölçümü. `sendRequest` dönünce toplanır.
  Duration? _pendingNetwork;
  int? _pendingStatus;
  int? _pendingBytes;
  String? _pendingError;

  @override
  void initState() {
    super.initState();
    _buildManager();
  }

  void _buildManager() {
    _manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
      isEnableLogger: _loggerEnabled,
      fileManager: _fileManager,
      interceptor: MetricsInterceptor((key, elapsed, status, bytes, error) {
        _pendingNetwork = elapsed;
        _pendingStatus = status;
        _pendingBytes = bytes;
        _pendingError = error;
      }),
    );
  }

  Future<void> _send() async {
    setState(() => _busy = true);

    _pendingNetwork = null;
    _pendingStatus = null;
    _pendingBytes = null;
    _pendingError = null;

    final expiration =
        _cacheEnabled ? Duration(seconds: _cacheSeconds) : null;
    final stopwatch = Stopwatch()..start();
    String resultText;

    try {
      if (_endpoint.isList) {
        final result = await _manager.sendRequest<Post, List<Post>>(
          _endpoint.path,
          parseModel: Post(),
          method: _endpoint.method,
          expiration: expiration,
        );
        resultText = switch (result) {
          NetworkSuccessResult(:final data) =>
            '✅ ${data.length} kayıt · ilk başlık: ${data.isEmpty ? "-" : data.first.title}',
          NetworkErrorResult(:final error) =>
            '⛔ ${error.statusCode} · ${error.description}',
        };
      } else {
        final result = await _manager.sendRequest<Post, Post>(
          _endpoint.path,
          parseModel: Post(),
          method: _endpoint.method,
          data: _endpoint.method == RequestType.POST
              ? Post(title: 'vexana', body: 'playground')
              : null,
          expiration: expiration,
        );
        resultText = switch (result) {
          NetworkSuccessResult(:final data) => '✅ id=${data.id} · ${data.title}',
          NetworkErrorResult(:final error) =>
            '⛔ ${error.statusCode} · ${error.description}',
        };
      }
    } catch (e) {
      resultText = '⛔ $e';
    }

    stopwatch.stop();

    /// Hiç ağ ölçümü gelmediyse istek cache'ten karşılanmıştır — bugün
    /// vexana'da cache hit'i görmenin başka yolu yok.
    final fromCache = _pendingNetwork == null && _pendingError == null;

    _metrics.add(
      RequestMetric(
        method: _endpoint.method.name.toUpperCase(),
        path: _endpoint.path,
        total: stopwatch.elapsed,
        network: _pendingNetwork,
        statusCode: _pendingStatus,
        bytes: _pendingBytes,
        errorType: _pendingError,
        fromCache: fromCache,
      ),
    );

    setState(() {
      _busy = false;
      _lastResult = resultText;
    });
  }

  Future<void> _clearCache() async {
    await _manager.cache.removeAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache temizlendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('vexana playground'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'jsonplaceholder.typicode.com',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final controls = _ControlsPanel(
            endpoint: _endpoint,
            cacheEnabled: _cacheEnabled,
            cacheSeconds: _cacheSeconds,
            loggerEnabled: _loggerEnabled,
            busy: _busy,
            lastResult: _lastResult,
            onEndpointChanged: (value) => setState(() => _endpoint = value),
            onCacheChanged: (value) => setState(() => _cacheEnabled = value),
            onCacheSecondsChanged: (value) =>
                setState(() => _cacheSeconds = value),
            onLoggerChanged: (value) {
              setState(() {
                _loggerEnabled = value;
                _buildManager();
              });
            },
            onSend: _send,
            onClearCache: _clearCache,
          );

          final metrics = _MetricsPanel(
            metrics: _metrics,
            onClear: () => setState(_metrics.clear),
          );

          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 380, child: controls),
                const VerticalDivider(width: 1),
                Expanded(child: metrics),
              ],
            );
          }
          return ListView(
            children: [
              controls,
              const Divider(height: 1),
              SizedBox(height: 520, child: metrics),
            ],
          );
        },
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.endpoint,
    required this.cacheEnabled,
    required this.cacheSeconds,
    required this.loggerEnabled,
    required this.busy,
    required this.lastResult,
    required this.onEndpointChanged,
    required this.onCacheChanged,
    required this.onCacheSecondsChanged,
    required this.onLoggerChanged,
    required this.onSend,
    required this.onClearCache,
  });

  final Endpoint endpoint;
  final bool cacheEnabled;
  final int cacheSeconds;
  final bool loggerEnabled;
  final bool busy;
  final String lastResult;
  final ValueChanged<Endpoint> onEndpointChanged;
  final ValueChanged<bool> onCacheChanged;
  final ValueChanged<int> onCacheSecondsChanged;
  final ValueChanged<bool> onLoggerChanged;
  final VoidCallback onSend;
  final VoidCallback onClearCache;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İstek', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<Endpoint>(
            value: endpoint,
            decoration: const InputDecoration(
              labelText: 'Endpoint',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final value in Endpoint.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) {
              if (value != null) onEndpointChanged(value);
            },
          ),
          const SizedBox(height: 20),
          Text('Seçenekler', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cache'),
            subtitle: Text('expiration: $cacheSeconds sn'),
            value: cacheEnabled,
            onChanged: onCacheChanged,
          ),
          if (cacheEnabled)
            Slider(
              value: cacheSeconds.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$cacheSeconds sn',
              onChanged: (value) => onCacheSecondsChanged(value.round()),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Logger'),
            subtitle: const Text('isEnableLogger'),
            value: loggerEnabled,
            onChanged: onLoggerChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : onSend,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Gönder'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onClearCache,
                child: const Text('Cache temizle'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(lastResult),
          ),
          if (cacheEnabled) ...[
            const SizedBox(height: 16),
            const _CacheWarning(),
          ],
        ],
      ),
    );
  }
}

/// Cache açıkken endpoint değiştirmek bugün yanlış veri döndürüyor.
///
/// Cache anahtarı `baseUrl + HTTP metodu`; path ve query anahtara girmiyor
/// (tasarım dokümanı C1). Playground bunu gizlemek yerine gösteriyor —
/// düzeltmesi planın F1 maddesi.
class _CacheWarning extends StatelessWidget {
  const _CacheWarning();

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
              'Bilinen sorun (C1): cache anahtarı baseUrl + HTTP metodu. '
              'Path anahtara girmediği için cache açıkken GET /posts ile '
              'GET /posts/1 aynı kaydı paylaşır.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel({required this.metrics, required this.onClear});

  final SessionMetrics metrics;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final summary = metrics.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(
                'Oturum ölçümleri',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(onPressed: onClear, child: const Text('Temizle')),
            ],
          ),
        ),
        if (summary.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SummaryTable(summary: summary),
          ),
          const SizedBox(height: 12),
        ],
        const Divider(height: 1),
        Expanded(
          child: metrics.entries.isEmpty
              ? const Center(child: Text('Henüz ölçüm yok.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: metrics.entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) => _MetricTile(
                    metric: metrics.entries[index],
                    isSlow: metrics.isSlow(metrics.entries[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SummaryTable extends StatelessWidget {
  const _SummaryTable({required this.summary});

  final List<EndpointSummary> summary;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 36,
        dataRowMinHeight: 34,
        dataRowMaxHeight: 34,
        columns: const [
          DataColumn(label: Text('endpoint')),
          DataColumn(label: Text('n'), numeric: true),
          DataColumn(label: Text('p50'), numeric: true),
          DataColumn(label: Text('p95'), numeric: true),
          DataColumn(label: Text('max'), numeric: true),
          DataColumn(label: Text('hata'), numeric: true),
          DataColumn(label: Text('cache'), numeric: true),
        ],
        rows: [
          for (final row in summary)
            DataRow(
              cells: [
                DataCell(Text(row.endpoint)),
                DataCell(Text('${row.count}')),
                DataCell(Text(_ms(row.p50))),
                DataCell(Text(_ms(row.p95))),
                DataCell(Text(_ms(row.max))),
                DataCell(Text('${row.errorCount}')),
                DataCell(Text('${row.cacheHitCount}')),
              ],
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric, required this.isSlow});

  final RequestMetric metric;
  final bool isSlow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final network = metric.network;
    final parse = metric.parseAndOverhead;

    return ListTile(
      dense: true,
      leading: Icon(
        metric.isError
            ? Icons.error_outline
            : metric.fromCache
                ? Icons.bolt
                : Icons.check_circle_outline,
        color: metric.isError
            ? scheme.error
            : metric.fromCache
                ? Colors.amber.shade700
                : Colors.green.shade600,
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${metric.method} ${metric.path}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          if (metric.statusCode != null)
            _Chip(
              label: '${metric.statusCode}',
              color: scheme.surfaceContainerHighest,
            ),
          if (metric.fromCache)
            const _Chip(label: 'cache hit', color: Color(0xFFFFF3C4)),
          if (isSlow) const _Chip(label: 'yavaş', color: Color(0xFFFFD9D9)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 16,
          children: [
            Text('toplam ${_ms(metric.total)}'),
            if (network != null) Text('ağ ${_ms(network)}'),
            if (parse != null) Text('parse+ek yük ${_ms(parse)}'),
            if (metric.bytes != null) Text(_bytes(metric.bytes!)),
            if (metric.errorType != null) Text(metric.errorType!),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

String _ms(Duration duration) {
  if (duration.inMilliseconds >= 1000) {
    return '${(duration.inMicroseconds / 1000000).toStringAsFixed(2)}s';
  }
  return '${duration.inMilliseconds}ms';
}

String _bytes(int value) {
  if (value >= 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  if (value >= 1024) return '${(value / 1024).toStringAsFixed(1)}KB';
  return '${value}B';
}
