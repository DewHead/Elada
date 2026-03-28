import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  test('test path provider downloads', () async {
    try {
      final dir = await getDownloadsDirectory();
      print('Downloads dir: \${dir?.path}');
    } catch (e) {
      print('Error: \$e');
      print('Stacktrace: \$st');
      rethrow;
    }
  });
}
