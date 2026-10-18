// ignore_for_file: avoid_print, avoid_dynamic_calls
import 'dart:convert';
import 'dart:io';

void main() {
  final result = Process.runSync(
    'dart',
    ['pub', 'deps', '--json'],
    workingDirectory: 'packages/vexana_core',
  );
  final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
  final packages = json['packages'] as List<dynamic>;
  final root = packages.firstWhere(
    (p) => (p as Map<String, dynamic>)['name'] == 'vexana_core',
  ) as Map<String, dynamic>;

  final visited = <String>{};
  final queue = <String>[...(root['dependencies'] as List).cast<String>()];

  while (queue.isNotEmpty) {
    final curr = queue.removeLast();
    if (!visited.add(curr)) continue;
    final pkg = packages.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p?['name'] == curr,
          orElse: () => null,
        );
    if (pkg != null) {
      queue.addAll((pkg['dependencies'] as List).cast<String>());
    }
  }

  final forbidden = visited
      .where(
        (p) => p == 'flutter' || p == 'sky_engine' || p.startsWith('flutter_'),
      )
      .toList();
  if (forbidden.isEmpty) {
    print('SUCCESS: vexana_core has NO flutter packages in transitive tree!');
    print('Direct deps: ${root['dependencies']}');
    print('Total transitive packages: ${visited.length}');
  } else {
    print('FAILED: found forbidden: $forbidden');
    exit(1);
  }
}
