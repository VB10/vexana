import 'package:equatable/equatable.dart';
import 'package:vexana/src/interface/index.dart';

/// [EmptyModel] is a model class that is used to
/// general model or primitive type.
final class EmptyModel extends INetworkModel<EmptyModel> with EquatableMixin {
  /// [EmptyModel] constructor is used to create a new [EmptyModel]
  EmptyModel({this.name});

  /// [name] is a getter method that returns the name of the model.
  final String? name;

  @override
  Map<String, Object>? toJson() => null;

  @override
  EmptyModel fromJson(Map<String, dynamic>? json) {
    return EmptyModel(name: json?['name'] as String? ?? '');
  }

  @override
  List<Object?> get props => [name];
}
