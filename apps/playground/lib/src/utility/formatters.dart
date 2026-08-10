extension DurationFormat on Duration {
  String get readable {
    if (inMilliseconds >= 1000) {
      return '${(inMicroseconds / 1000000).toStringAsFixed(2)}s';
    }
    return '${inMilliseconds}ms';
  }
}

extension ByteFormat on int {
  String get readableBytes {
    const kilobyte = 1024;
    const megabyte = kilobyte * 1024;

    if (this >= megabyte) {
      return '${(this / megabyte).toStringAsFixed(1)}MB';
    }
    if (this >= kilobyte) {
      return '${(this / kilobyte).toStringAsFixed(1)}KB';
    }
    return '${this}B';
  }
}
