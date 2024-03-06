/// Error when file manager is not found
final class FileManagerNotFoundException implements Exception {
  @override
  String toString() {
    return 'File Manager is not found';
  }
}
