## 0.1.0

- Initial release of `vexana_jaspr`.
- Built on `vexana_core` for Jaspr web framework support.
- Added `JasprLocalStorageFileManager` (`IFileManager` backed by `window.localStorage`).
- Added `JasprNoNetwork` handler (acts only while offline, with `retry` / `dismiss` callbacks) and `JasprNoNetworkComponent`.
- Added `JasprNetworkCheck` using `window.navigator.onLine`.
