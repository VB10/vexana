import 'package:flutter/foundation.dart';

/// Interface for network model

@immutable
abstract class INetworkModel<T> {
  /// Default constructor for all network model
  const INetworkModel();

  /// Convert to json for request body
  Map<String, dynamic>? toJson();

  /// Parse json to model
  T fromJson(Map<String, dynamic> json);
}
