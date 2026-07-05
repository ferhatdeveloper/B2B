final Map<String, String> _mem = {};

String? readKey(String key) => _mem[key];
void writeKey(String key, String value) => _mem[key] = value;
void removeKey(String key) => _mem.remove(key);
