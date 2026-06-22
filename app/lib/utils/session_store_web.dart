import 'package:web/web.dart' as web;

String? readKey(String key) => web.window.localStorage.getItem(key);
void writeKey(String key, String value) => web.window.localStorage.setItem(key, value);
void removeKey(String key) => web.window.localStorage.removeItem(key);
