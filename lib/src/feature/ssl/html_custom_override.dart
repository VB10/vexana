import 'package:vexana/src/feature/ssl/http_custom_override.dart';

/// This class is not implemented yet.
HttpCustomOverride createAdapter() => _GeneralCustomOverride();

class _GeneralCustomOverride extends HttpCustomOverride {
  @override
  void make() {
    throw UnimplementedError();
  }
}
