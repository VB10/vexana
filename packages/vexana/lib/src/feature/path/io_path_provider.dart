import 'package:path_provider/path_provider.dart';
import 'package:vexana/src/feature/path/custom_path_provider.dart';

/// Custom path provider
CustomPathProvider createPathProviderAdapter() => _IOPathProviderManager();

class _IOPathProviderManager implements CustomPathProvider {
  @override
  Future<String> applicationDirectoryPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }
}
