// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verilen eleman sayısında gerçekçi bir JSON gövdesi üretir.
String makeBody(int itemCount) {
  final items = List.generate(
    itemCount,
    (i) => {
      'id': i,
      'title': 'item $i başlık metni',
      'completed': i.isEven,
      'tags': ['a', 'b', 'c'],
    },
  );
  return jsonEncode(items);
}

Future<int> timeAsyncMicros(Future<void> Function() body, int runs) async {
  // Isıtma: ilk isolate spawn'ı ve JIT maliyetini ölçüme karıştırma.
  await body();
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    await body();
  }
  sw.stop();
  return sw.elapsedMicroseconds ~/ runs;
}

int timeSyncMicros(void Function() body, int runs) {
  body();
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    body();
  }
  sw.stop();
  return sw.elapsedMicroseconds ~/ runs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Spec §11-T3: dio'nun varsayılan BackgroundTransformer'ı her yanıtta
  // compute() çağırıyor. Bu ölçüm, küçük payload'da isolate spawn maliyetinin
  // decode kazancını yiyip yemediğini belirler. P1 (transformer eşiği)
  // maddesinin kabul kriteri budur — ölçüm doğrulamazsa P1 düşer.
  test('compute vs senkron jsonDecode', () async {
    const sizes = <String, int>{
      'küçük': 1,
      'orta': 150,
      'büyük': 15000,
    };

    print('');
    print('| payload | boyut | senkron | compute | oran |');
    print('|---|---|---|---|---|');

    for (final entry in sizes.entries) {
      final body = makeBody(entry.value);
      final runs = entry.value > 1000 ? 5 : 50;

      final sync = timeSyncMicros(() => jsonDecode(body), runs);
      final async = await timeAsyncMicros(
        () async => compute(jsonDecode, body),
        runs,
      );

      final ratio = async / (sync == 0 ? 1 : sync);
      print(
        '| ${entry.key} | ${body.length} B | $sync µs | $async µs | '
        '${ratio.toStringAsFixed(1)}x |',
      );
    }
    print('');
    print('oran > 1 => compute o boyutta KAYIP');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
