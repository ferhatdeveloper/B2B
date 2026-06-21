import 'package:web/web.dart' as web;

const _key = 'zen_b2b_session';

String? readSession() => web.window.localStorage.getItem(_key);
void writeSession(String value) => web.window.localStorage.setItem(_key, value);
void clearSession() => web.window.localStorage.removeItem(_key);
