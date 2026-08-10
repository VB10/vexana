import 'package:flutter/material.dart';
import 'package:playground/src/model/playground_options.dart';
import 'package:playground/src/model/post.dart';
import 'package:playground/src/service/metrics_interceptor.dart';
import 'package:playground/src/service/session_metrics.dart';
import 'package:playground/src/view/playground_view.dart';
import 'package:vexana/vexana.dart';

mixin PlaygroundViewMixin on State<PlaygroundView> {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  final SessionMetrics metrics = SessionMetrics();
  final IFileManager _fileManager = LocalPreferences();

  late NetworkManager<EmptyModel> _manager;

  NetworkSample _sample = NetworkSample.empty;

  PlaygroundOptions options = const PlaygroundOptions();
  bool isBusy = false;
  String lastResult = 'No request sent yet.';

  @override
  void initState() {
    super.initState();
    _rebuildManager();
  }

  void updateOptions(PlaygroundOptions next) {
    final loggerChanged = next.loggerEnabled != options.loggerEnabled;

    setState(() {
      options = next;
      if (loggerChanged) _rebuildManager();
    });
  }

  Future<void> send() async {
    setState(() => isBusy = true);
    _sample = NetworkSample.empty;

    final stopwatch = Stopwatch()..start();
    final message = await _perform();
    stopwatch.stop();

    metrics.add(
      _sample.toMetric(endpoint: options.endpoint, total: stopwatch.elapsed),
    );

    setState(() {
      isBusy = false;
      lastResult = message;
    });
  }

  Future<void> clearCache() async {
    await _manager.cache.removeAll();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  void clearMetrics() => setState(metrics.clear);

  void _rebuildManager() {
    _manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: _baseUrl),
      isEnableLogger: options.loggerEnabled,
      fileManager: _fileManager,
      interceptor: MetricsInterceptor((sample) => _sample = sample),
    );
  }

  Future<String> _perform() async {
    try {
      final result = options.endpoint.isList
          ? await _requestList()
          : await _requestSingle();
      return _describe(result);
    } catch (error) {
      return '⛔ $error';
    }
  }

  Future<NetworkResult<List<Post>, EmptyModel>> _requestList() {
    return _manager.sendRequest<Post, List<Post>>(
      options.endpoint.path,
      parseModel: const Post(),
      method: options.endpoint.method,
      expiration: options.expiration,
    );
  }

  Future<NetworkResult<Post, EmptyModel>> _requestSingle() {
    final endpoint = options.endpoint;

    return _manager.sendRequest<Post, Post>(
      endpoint.path,
      parseModel: const Post(),
      method: endpoint.method,
      data: endpoint.method == RequestType.POST
          ? const Post(title: 'vexana', body: 'playground')
          : null,
      expiration: options.expiration,
    );
  }

  String _describe<T>(NetworkResult<T, EmptyModel> result) {
    return switch (result) {
      NetworkSuccessResult(:final data) => '✅ ${_summarize(data)}',
      NetworkErrorResult(:final error) =>
        '⛔ ${error.statusCode} · ${error.description}',
    };
  }

  String _summarize(Object? data) {
    return switch (data) {
      final List<Post> posts when posts.isEmpty => '0 records',
      final List<Post> posts =>
        '${posts.length} records · first title: ${posts.first.title}',
      final Post post => 'id=${post.id} · ${post.title}',
      _ => 'OK',
    };
  }
}
