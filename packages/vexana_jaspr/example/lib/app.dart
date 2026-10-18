import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:vexana_jaspr/vexana_jaspr.dart';

/// Todo model extending INetworkModel.
final class TodoItem extends INetworkModel<TodoItem> {
  const TodoItem({this.id, this.title, this.completed});

  final int? id;
  final String? title;
  final bool? completed;

  @override
  TodoItem fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      completed: json['completed'] as bool?,
    );
  }

  @override
  Map<String, dynamic>? toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
      };
}

/// Main application component for Jaspr example.
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final INetworkManager<EmptyModel> _networkManager;
  String _status = 'Idle';
  String? _todoTitle;
  JasprRetryCallback? _pendingRetry;

  @override
  void initState() {
    super.initState();
    _networkManager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
      fileManager: JasprLocalStorageFileManager(),
      noNetwork: JasprNoNetwork(
        onNetworkLoss: (retry, dismiss) {
          setState(() => _pendingRetry = retry);
        },
      ),
    );
  }

  void _retry() {
    final retry = _pendingRetry;
    setState(() => _pendingRetry = null);
    retry?.call();
  }

  Future<void> _fetchTodo() async {
    setState(() => _status = 'Fetching...');
    final response = await _networkManager.send<TodoItem, TodoItem>(
      '/todos/1',
      parseModel: const TodoItem(),
      method: RequestType.GET,
      isErrorDialog: true,
    );

    if (response.data != null) {
      setState(() {
        _status = 'Success!';
        _todoTitle = response.data?.title;
      });
    } else {
      setState(() {
        _status = 'Error: ${response.error?.statusCode}';
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div([
      if (_pendingRetry != null) JasprNoNetworkComponent(onRetry: _retry),
      h1([Component.text('Vexana Jaspr Demo')]),
      p([Component.text('Status: $_status')]),
      if (_todoTitle != null) p([Component.text('Todo: $_todoTitle')]),
      button(
        onClick: _fetchTodo,
        [Component.text('Fetch Todo #1')],
      ),
    ]);
  }
}
