import 'package:vexana/src/feature/path/custom_path_provider.dart';

/// Custom path provider
CustomPathProvider createPathProviderAdapter() => _HtmlPathProviderManager();

class _HtmlPathProviderManager implements CustomPathProvider {
  @override
  Future<String> applicationDirectoryPath() async {
    return 'web';
  }
}
