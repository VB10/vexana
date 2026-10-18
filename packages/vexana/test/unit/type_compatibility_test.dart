import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart' as vexana;
import 'package:vexana_core/vexana_core.dart' as core;

// Class extending vexana_core's INetworkModel directly
final class CorePing extends core.INetworkModel<CorePing> {
  const CorePing();
  @override
  CorePing fromJson(Map<String, dynamic> json) => const CorePing();
  @override
  Map<String, dynamic>? toJson() => null;
}

// Class extending vexana's (re-exported) INetworkModel
final class FlutterPing extends vexana.INetworkModel<FlutterPing> {
  const FlutterPing();
  @override
  FlutterPing fromJson(Map<String, dynamic> json) => const FlutterPing();
  @override
  Map<String, dynamic>? toJson() => null;
}

void main() {
  test('INetworkModel from vexana and vexana_core is identical type', () {
    expect(core.INetworkModel, equals(vexana.INetworkModel));
    expect(identical(core.INetworkModel, vexana.INetworkModel), isTrue);
  });

  test('CorePing can be assigned to vexana.INetworkModel', () {
    const core.INetworkModel<CorePing> coreModel = CorePing();
    const vexana.INetworkModel<CorePing> flutterModel = coreModel;
    expect(flutterModel, isNotNull);
  });

  test('vexana NetworkManager accepts model extending core.INetworkModel', () {
    final manager = vexana.NetworkManager<vexana.EmptyModel>(
      options:
          vexana.BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
      isEnableTest: true,
    );

    // Verify type check compiles and runs without any cast or type error
    expect(
      () => manager.send<CorePing, CorePing>(
        '/ping',
        parseModel: const CorePing(),
        method: vexana.RequestType.GET,
      ),
      returnsNormally,
    );
  });
}
