import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void downloadFile(Uint8List bytes, String fileName) {
  final blob = web.Blob([bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
