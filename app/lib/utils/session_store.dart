import 'session_store_stub.dart' if (dart.library.js_interop) 'session_store_web.dart' as impl;

/// Lightweight session persistence backed by browser localStorage on web
/// (synchronous and reliable across full-page redirects, e.g. Stripe Checkout).
String? readSession() => impl.readSession();
void writeSession(String value) => impl.writeSession(value);
void clearSession() => impl.clearSession();
