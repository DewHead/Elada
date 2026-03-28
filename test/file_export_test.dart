import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/file_export_service.dart';

void main() {
  test('tests file export service', () async {
    final service = FileExportService();
    try {
      final path = await service.saveFile(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'test.pdf',
      );
      print('Saved to: \$path');
    } catch (e) {
      print('Error: \$e');
      print('Stacktrace: \$st');
      rethrow;
    }
  });
}
