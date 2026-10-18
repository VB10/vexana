/// Manage your network layer with dio.
///
/// Re-exports `vexana_core` and provides Flutter-specific features such as
/// `LocalFile`, `LocalPreferences`, and `NoNetwork`.
library vexana;

// CORE
export 'package:vexana_core/vexana_core.dart';

// CACHE (Flutter-specific)
export 'src/cache/file/local_file.dart';
export 'src/cache/shared/local_preferences.dart';

// FEATURE (Flutter-specific)
export 'src/feature/no_network/index.dart';
