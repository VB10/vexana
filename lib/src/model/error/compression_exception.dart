/// Exception for compression errors
final class CompressionException<T> implements Exception {
  /// Constructor for CompressionException
  CompressionException(this.type);

  /// Compression type
  final T type;

  @override
  String toString() {
    return 'CompressionException: $type';
  }
}
