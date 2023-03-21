import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../interface/INetworkModel.dart';

@immutable
class EmptyModel extends INetworkModel<EmptyModel> with EquatableMixin {
  final String? name;

  EmptyModel({
    this.name,
  });

  @override
  List<Object?> get props => [name];

  EmptyModel copyWith({
    String? name,
  }) {
    return EmptyModel(
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  EmptyModel fromJson(Map<String, dynamic> json) {
    return EmptyModel(
      name: json['name'] as String?,
    );
  }
}
