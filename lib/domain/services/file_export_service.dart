import 'dart:io';
import 'dart:typed_data';
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

    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// Finds the downloads directory for the current platform.
  Future<String> getDownloadsDirectoryPath() async {
    Directory? downloadsDir;

    if (Platform.isAndroid || Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    return downloadsDir?.path ?? (await getTemporaryDirectory()).path;
  }
}
