// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

class Todo {
  const Todo({this.id, this.title});
  final int? id;
  final String? title;

  Todo fromJson(Map<String, dynamic> json) =>
      Todo(id: json['id'] as int?, title: json['title'] as String?);
}

/// Mevcut implementasyon.
/// packages/vexana/lib/src/mixin/network_manager_response.dart:118-126
/// whereType().toList() (kopya 1) -> map().cast<T>().toList() (kopya 2)
List<Todo> currentImpl(List<dynamic> body, Todo model) {
  final items = body.whereType<Map<String, dynamic>>().toList();
  return items.map(model.fromJson).cast<Todo>().toList();
}

/// Plan B'de gelecek tek geçişli hali. Karşılaştırma tabanı.
List<Todo> singlePass(List<dynamic> body, Todo model) {
  final out = <Todo>[];
  for (final item in body) {
    if (item is Map<String, dynamic>) out.add(model.fromJson(item));
  }
  return out;
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
  // Spec P5'in kabul kriteri.
  test('liste parse — mevcut vs tek geçiş', () {
    const model = Todo();

    print('');
    print('| eleman | mevcut | tek geçiş | oran |');
    print('|---|---|---|---|');

    for (final count in [10, 1000, 50000]) {
      final body = List<dynamic>.generate(
        count,
        (i) => <String, dynamic>{'id': i, 'title': 'item $i'},
      );
      final runs = count > 10000 ? 20 : 200;

      final current = timeSyncMicros(() => currentImpl(body, model), runs);
      final single = timeSyncMicros(() => singlePass(body, model), runs);

      final ratio = current / (single == 0 ? 1 : single);
      print(
        '| $count | $current µs | $single µs | ${ratio.toStringAsFixed(2)}x |',
      );
    }
    print('');
    print('oran > 1 => tek geçiş daha hızlı');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
