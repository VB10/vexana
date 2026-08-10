import 'package:flutter/foundation.dart';
import 'package:playground/src/model/endpoint.dart';

@immutable
class PlaygroundOptions {
  const PlaygroundOptions({
    this.endpoint = Endpoint.posts,
    this.cacheEnabled = false,
    this.cacheSeconds = 30,
    this.loggerEnabled = false,
  });

  final Endpoint endpoint;
  final bool cacheEnabled;
  final int cacheSeconds;
  final bool loggerEnabled;

  Duration? get expiration =>
      cacheEnabled ? Duration(seconds: cacheSeconds) : null;

  PlaygroundOptions copyWith({
    Endpoint? endpoint,
    bool? cacheEnabled,
    int? cacheSeconds,
    bool? loggerEnabled,
  }) {
    return PlaygroundOptions(
      endpoint: endpoint ?? this.endpoint,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      cacheSeconds: cacheSeconds ?? this.cacheSeconds,
      loggerEnabled: loggerEnabled ?? this.loggerEnabled,
    );
  }
}
