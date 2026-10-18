import 'package:web/web.dart' as web;

/// Platform web implementation checking window.navigator.onLine.
bool getPlatformOnline() {
  try {
    return web.window.navigator.onLine;
  } catch (_) {
    return true;
  }
}
