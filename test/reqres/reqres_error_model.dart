import 'package:vexana/vexana.dart';

class UserError extends INetworkModel<UserError> {
  String? error;

  UserError({
    this.error,
  });

  @override
  UserError fromJson(Map<String, dynamic> json) => UserError.fromJson(json);

  factory UserError.fromJson(Map<String, dynamic> json) {
    return UserError(
      error: json['error'] as String?,
    );
  }

  @override
  Map<String, dynamic>? toJson() => _toJson();

  Map<String, dynamic> _toJson() {
    return {
      'error': error,
    };
  }

  UserError copyWith({
    String? error,
  }) {
    return UserError(
      error: error ?? this.error,
    );
  }
}
