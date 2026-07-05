// Non-web fallback: file download is only meaningful in a browser.
void downloadTextFile(String filename, String content, {String mime = 'text/csv'}) {
  throw UnsupportedError('downloadTextFile is only available on the web target.');
}
