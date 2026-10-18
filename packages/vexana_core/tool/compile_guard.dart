// ignore_for_file: avoid_print
import 'package:vexana_core/vexana_core.dart';

final class Ping extends INetworkModel<Ping> {
  const Ping();
  @override
  Ping fromJson(Map<String, dynamic> json) => const Ping();
  @override
  Map<String, dynamic>? toJson() => null;
}

void main() => print(const Ping());
