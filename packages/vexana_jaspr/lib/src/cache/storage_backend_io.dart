import 'package:vexana_jaspr/src/cache/storage_backend.dart';

/// VM / Server-side default backend.
IStorageBackend createDefaultStorageBackend() => InMemoryStorageBackend();
