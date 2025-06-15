/// Request behavior flags for controlling specific NetworkManager features.
///
/// These flags provide a type-safe way to control various aspects of
/// network requests without relying on magic strings in the extra map.
///
/// Example:
/// ```dart
/// // Disable refresh token for a specific request
/// networkManager.send(
///   '/api/login',
///   parseModel: LoginModel(),
///   method: RequestType.POST,
///   requestFlags: {RequestFlag.disableRefreshToken},
/// );
/// ```
enum RequestFlag {
  /// Disables automatic refresh token handling for this request.
  ///
  /// When this flag is set, the NetworkManager will not attempt to
  /// refresh the authentication token if the request fails with a 401
  /// status code. The error will be returned immediately.
  ///
  /// Use this flag for:
  /// - Login requests where refresh token doesn't make sense
  /// - Logout requests to prevent infinite loops
  /// - Public API calls that don't require authentication
  /// - One-time authentication flows
  disableRefreshToken,
}

/// Extension methods for RequestFlag enum to provide utility functions.
extension RequestFlagExtension on Set<RequestFlag> {
  /// Checks if the set contains the disableRefreshToken flag.
  bool get shouldDisableRefreshToken =>
      contains(RequestFlag.disableRefreshToken);

  /// Converts the flags to a map for storing in Dio's extra field.
  ///
  /// This method is used internally by NetworkManager to convert
  /// the type-safe flags into a format that can be stored in
  /// Dio's RequestOptions.extra map.
  Map<String, bool> toExtraMap() {
    return {
      for (final flag in this) '_flag_${flag.name}': true,
    };
  }

  /// Creates a RequestFlag set from a Dio extra map.
  ///
  /// This method is used internally by NetworkManager to convert
  /// the extra map back into type-safe RequestFlag values.
  static Set<RequestFlag> fromExtraMap(Map<String, dynamic>? extra) {
    if (extra == null) return <RequestFlag>{};

    final flags = <RequestFlag>{};
    for (final flag in RequestFlag.values) {
      if (extra['_flag_${flag.name}'] == true) {
        flags.add(flag);
      }
    }
    return flags;
  }
}
