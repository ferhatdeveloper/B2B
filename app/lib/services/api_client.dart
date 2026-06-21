import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Thin PostgREST client mirroring the TypeScript `postgrestClient`:
/// schema selection via `Accept-Profile` / `Content-Profile` headers.
class PostgrestException implements Exception {
  PostgrestException(this.method, this.path, this.status, this.body);

  final String method;
  final String path;
  final int status;
  final String body;

  @override
  String toString() => 'PostgREST $method $path: $status $body';
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _headers(String schema, {String? prefer}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Profile': schema,
      'Content-Profile': schema,
    };
    if (prefer != null) headers['Prefer'] = prefer;
    return headers;
  }

  Uri _uri(String path, Map<String, String>? query) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalized')
        .replace(queryParameters: (query == null || query.isEmpty) ? null : query);
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    String schema = ApiConfig.schemaPublic,
  }) async {
    final res = await _client.get(_uri(path, query), headers: _headers(schema));
    return _parse('GET', path, res);
  }

  Future<dynamic> post(
    String path,
    Object body, {
    String schema = ApiConfig.schemaPublic,
    String prefer = 'return=representation',
  }) async {
    final res = await _client.post(
      _uri(path, null),
      headers: _headers(schema, prefer: prefer),
      body: jsonEncode(body),
    );
    return _parse('POST', path, res);
  }

  Future<dynamic> rpc(
    String name,
    Map<String, dynamic> body, {
    String schema = ApiConfig.schemaLogic,
  }) {
    return post('/rpc/$name', body, schema: schema);
  }

  dynamic _parse(String method, String path, http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PostgrestException(method, path, res.statusCode, res.body);
    }
    if (res.body.isEmpty) return null;
    final contentType = res.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      return jsonDecode(res.body);
    }
    return res.body;
  }
}
