## 1.0.0

- Initial release of `vexana_core`.
- Extracted pure Dart networking core from `vexana`.
- Zero Flutter SDK dependencies; fully compatible with `dart2js` and Jaspr.
- Introduced `INoNetworkHandler` interface.
- Isolate-based background decode (`Isolate.run`) on IO and inline decode on Web.
