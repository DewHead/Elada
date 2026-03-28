import 'package:flutter_test/flutter_test.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  bool throwError = false;

  @override
  Future<String?> getDownloadsPath() async {
    if (throwError) throw Exception('Failed to get downloads path');
    return null; // Return null to trigger fallback
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return 'docs_path';
  }

  @override
  Future<String?> getTemporaryPath() async {
    return 'temp_path';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FileExportService service;
  late MockPathProviderPlatform mockPathProvider;

  setUp(() {
    service = FileExportService();
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;
  });

  group('FileExportService', () {
    test(
      'getDownloadsDirectoryPath should fallback to temp if downloads is null',
      () async {
        final path = await service.getDownloadsDirectoryPath();
        // On non-mobile, it calls getDownloadsPath() which returns null in our mock
        // So it should fallback to getTemporaryPath() which is 'temp_path'
        // UNLESS it's running on a "mobile" platform in the test environment.
        // Platform.isAndroid/isIOS depends on the host OS unless mocked.

        if (Platform.isAndroid || Platform.isIOS) {
          expect(path, 'docs_path');
        } else {
          expect(path, 'temp_path');
        }
      },
    );

    test(
      'getDownloadsDirectoryPath should fallback to temp if path_provider throws',
      () async {
        mockPathProvider.throwError = true;
        final path = await service.getDownloadsDirectoryPath();
        expect(path, 'temp_path');
      },
    );
  });
}
