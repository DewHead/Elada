import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileExportService {
  /// Saves the PDF bytes to the given filename in the specified directory.
  /// If [directoryPath] is not provided, it will attempt to find the Downloads directory.
  Future<String> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? directoryPath,
  }) async {
    final String baseDir = directoryPath ?? await getDownloadsDirectoryPath();
    final String filePath = p.join(baseDir, fileName);

    try {
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
    } catch (e) {
      rethrow;
    }

    return filePath;
  }

  /// Finds the downloads directory for the current platform.
  Future<String> getDownloadsDirectoryPath() async {
    Directory? downloadsDir;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          final linuxDownloads = Directory('$home/Downloads');
          if (linuxDownloads.existsSync()) {
            return linuxDownloads.path;
          }
        }
        return '/tmp';
      } else {
        downloadsDir = await getDownloadsDirectory();
      }
    } catch (e) {
      // Primary attempts failed
    }

    if (downloadsDir != null) {
      return downloadsDir.path;
    }

    try {
      // Fallback to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      return tempDir.path;
    } catch (e) {
      // Last resort fallback to current directory or a safe path on Linux
      try {
        final currentDir = Directory.current;
        return currentDir.path;
      } catch (e2) {
        return '/tmp'; // Hardcoded fallback for Linux/Unix
      }
    }
  }
}
