import 'session_store_stub.dart' if (dart.library.js_interop) 'session_store_web.dart' as impl;

/// Lightweight key/value persistence backed by browser localStorage on web
/// (synchronous and reliable across full-page redirects, e.g. Stripe Checkout).
String? readKey(String key) => impl.readKey(key);
void writeKey(String key, String value) => impl.writeKey(key, value);
void removeKey(String key) => impl.removeKey(key);

// Session convenience wrappers.
const _sessionKey = 'zen_b2b_session';
String? readSession() => readKey(_sessionKey);
void writeSession(String value) => writeKey(_sessionKey, value);
void clearSession() => removeKey(_sessionKey);
