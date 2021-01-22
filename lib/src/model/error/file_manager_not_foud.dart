class FileManagerNotFound implements Exception {
  String get message => 'File Manager is not found';

  @override
  String toString() {
    return message;
  }
}
