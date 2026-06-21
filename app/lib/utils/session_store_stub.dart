String? _mem;

String? readSession() => _mem;
void writeSession(String value) => _mem = value;
void clearSession() => _mem = null;
