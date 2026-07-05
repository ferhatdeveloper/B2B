import 'location_stub.dart' if (dart.library.js_interop) 'location_web.dart' as impl;

/// Current URL query string (web), e.g. "?payment=success". Empty off-web.
String currentSearch() => impl.currentSearch();

/// Removes the query string from the address bar without reloading (web).
void clearQuery() => impl.clearQuery();
