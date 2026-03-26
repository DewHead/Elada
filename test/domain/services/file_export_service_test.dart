import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileExportService', () {
    late FileExportService fileExportService;
    late Directory tempDir;

    setUp(() async {
      fileExportService = FileExportService();
      tempDir = await Directory.systemTemp.createTemp('elada_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('should save file to specified directory', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final fileName = 'test_invoice.pdf';
      
      final filePath = await fileExportService.saveFile(
        bytes: bytes,
        fileName: fileName,
        directoryPath: tempDir.path,
      );

      final file = File(filePath);
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), bytes);
      expect(p.basename(filePath), fileName);
    });
  });
}
