import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:vexana/src/model/error/compression_exception.dart';
import 'package:vexana/vexana.dart';

/// Service for handling data compression
final class NetworkCompressionService {
  /// Constructor for CompressionService
  const NetworkCompressionService();

  /// Compresses data based on the specified compression type
  /// works only gzip compression
  static Uint8List gzipCompressModelMap(
    Map<String, dynamic> model,
  ) {
    try {
      final jsonString = jsonEncode(model);
      final bytes = utf8.encode(jsonString);
      final compressed = const GZipEncoder().encode(bytes);
      return Uint8List.fromList(compressed);
    } catch (e) {
      throw CompressionException(model);
    }
  }

  /// Compresses a [FormData] object using gzip compression
  ///
  /// [formData] is the [FormData] object to compress
  ///
  /// Returns a [Uint8List] containing the compressed data
  static Uint8List gzipCompressModelFormData(
    FormData formData,
  ) {
    try {
      final jsonString = jsonEncode(formData);
      final bytes = utf8.encode(jsonString);
      final compressed = const GZipEncoder().encode(bytes);
      return Uint8List.fromList(compressed);
    } catch (e) {
      throw CompressionException(formData);
    }
  }
}
