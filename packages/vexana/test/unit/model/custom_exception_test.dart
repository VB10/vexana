import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/model/error/file_manager_not_found_exception.dart';

void main() {
  setUp(() {});
  test('File not found is working', () {
    final fileNotFound = FileManagerNotFoundException();

    expect(fileNotFound, isA<FileManagerNotFoundException>());

    expect(fileNotFound.toString(), 'File Manager is not found');
  });
}
