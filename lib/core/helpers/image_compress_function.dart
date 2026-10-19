import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressHelper {
  Future<File> compressFile(
    File file, {
    int quality = 88,
    int rotate = 0,
  }) async {
    try {
      final inputPath = file.absolute.path;

      final filename = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'image_${DateTime.now().millisecondsSinceEpoch}';
      // الضغط بيطلع JPEG دايماً، والمكتبة بترمي لو الامتداد مش jpg، فكانت
      // صور HEIC و PNG بترجع زي ما هي من غير ضغط والباك بيرفض HEIC
      final dot = filename.lastIndexOf('.');
      final baseName = dot > 0 ? filename.substring(0, dot) : filename;
      final targetPath =
          '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$baseName.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        inputPath,
        targetPath,
        quality: quality,
        rotate: rotate,
      );

      // If compression returned null, fall back to the original file   
      if (result == null) return file;

      // The plugin may return different file-like types (File, XFile). Normalize to File.
      String resultPath;
      try {
        // Prefer .path if available
        final dynamic r = result;
        resultPath = (r.path ?? r.name ?? '').toString();
      } catch (_) {
        // Fallback to targetPath
        resultPath = targetPath;
      }

      final outFile = File(resultPath);

      log('Original size: ${file.lengthSync()} bytes');
      log('Compressed size: ${outFile.lengthSync()} bytes');

      return outFile;
    } catch (e) {
      // On any error return the original file so callers can continue
      log('Image compression failed: $e');
      return file;
    }
  }
}
