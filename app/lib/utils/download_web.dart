import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Triggers a browser download of [content]. A UTF-8 BOM is prepended so Excel
/// renders Turkish characters correctly.
void downloadTextFile(String filename, String content, {String mime = 'text/csv'}) {
  final bytes = utf8.encode('\uFEFF$content');
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: '$mime;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
