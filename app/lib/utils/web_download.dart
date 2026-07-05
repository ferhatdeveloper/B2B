import 'download_stub.dart' if (dart.library.js_interop) 'download_web.dart' as impl;

/// Triggers a browser download (web). No-op/unsupported off-web.
void downloadTextFile(String filename, String content, {String mime = 'text/csv'}) =>
    impl.downloadTextFile(filename, content, mime: mime);

/// Builds a CSV string from headers + rows (semicolon-separated for Excel TR).
String toCsv(List<String> headers, List<List<String>> rows) {
  String cell(String v) => '"${v.replaceAll('"', '""')}"';
  final buffer = StringBuffer()..writeln(headers.map(cell).join(';'));
  for (final row in rows) {
    buffer.writeln(row.map(cell).join(';'));
  }
  return buffer.toString();
}
