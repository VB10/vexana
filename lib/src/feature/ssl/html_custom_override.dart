import 'package:vexana/src/feature/ssl/http_custom_override.dart';

/// This class is not implemented yet.
HttpCustomOverride createAdapter() => _GeneralCustomOverride();

final class _GeneralCustomOverride with HttpCustomOverride {
  @override
  void make() {
    throw UnimplementedError();
  }
}
