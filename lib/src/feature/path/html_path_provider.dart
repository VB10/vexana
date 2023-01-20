import 'package:vexana/src/feature/path/custom_path_provider.dart';

CustomPathProvider createPathProviderAdapter() => _HtmlPathProviderManager();

class _HtmlPathProviderManager implements CustomPathProvider {
  @override
  Future<String> applicationDirectoryPath() async {
    // TODO: will support web for sebmast
    print('vb web');
    return 'web';
  }
}
