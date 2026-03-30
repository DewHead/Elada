import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:elada/domain/services/web_download.dart';

class FileExportService {
  /// Saves the PDF bytes to the given filename in the specified directory.
  /// If [directoryPath] is not provided, it will attempt to find the Downloads directory.
  Future<String> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? directoryPath,
  }) async {
    if (kIsWeb) {
      downloadFile(bytes, fileName);
      return "web_download";
    }

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
    if (kIsWeb) return '';

    Directory? downloadsDir;

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else if (!kIsWeb && Platform.isLinux) {
        final home = !kIsWeb ? Platform.environment['HOME'] : null;
        if (home != null) {
          final linuxDownloads = Directory('$home/Downloads');
          if (linuxDownloads.existsSync()) {
            return linuxDownloads.path;
          }
        }
        return '/tmp';
      } else if (!kIsWeb) {
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
      if (kIsWeb) return '';
      final Directory tempDir = await getTemporaryDirectory();
      return tempDir.path;
    } catch (e) {
      // Last resort fallback to current directory or a safe path on Linux
      if (kIsWeb) return '';
      try {
        final currentDir = Directory.current;
        return currentDir.path;
      } catch (e2) {
        return '/tmp'; // Hardcoded fallback for Linux/Unix
      }
    }
  }
}
