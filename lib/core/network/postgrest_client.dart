import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class PostgrestClient {
  PostgrestClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.postgrestUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _httpClient;
  final String _baseUrl;

  Future<List<Map<String, dynamic>>> get(
    String path, {
    Map<String, Object?> query = const {},
    String schema = AppConfig.publicSchema,
  }) async {
    final uri = _uri(path, query);
    final response = await _httpClient.get(uri, headers: _headers(schema));
    final decoded = _decode(response, 'GET', path);
    if (decoded is List) {
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    throw const ApiException('Beklenen liste yaniti alinamadi.');
  }

  Future<Map<String, dynamic>?> getOne(
    String path, {
    Map<String, Object?> query = const {},
    String schema = AppConfig.publicSchema,
  }) async {
    final rows = await get(path, query: {...query, 'limit': 1}, schema: schema);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> post(
    String path,
    Object body, {
    String schema = AppConfig.publicSchema,
    String prefer = 'return=representation',
  }) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: _headers(schema, prefer: prefer),
      body: jsonEncode(body),
    );
    final decoded = _decode(response, 'POST', path);
    if (decoded == null) return const [];
    if (decoded is List) {
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    if (decoded is Map) return [Map<String, dynamic>.from(decoded)];
    throw const ApiException('Beklenen kayit yaniti alinamadi.');
  }

  Future<List<Map<String, dynamic>>> patch(
    String path,
    Object body, {
    String schema = AppConfig.publicSchema,
    String prefer = 'return=representation',
  }) async {
    final response = await _httpClient.patch(
      _uri(path),
      headers: _headers(schema, prefer: prefer),
      body: jsonEncode(body),
    );
    final decoded = _decode(response, 'PATCH', path);
    if (decoded == null) return const [];
    if (decoded is List) {
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    throw const ApiException('Beklenen guncelleme yaniti alinamadi.');
  }

  Future<Map<String, dynamic>?> rpc(
    String name,
    Map<String, Object?> params, {
    String schema = AppConfig.logicSchema,
  }) async {
    final rows = await post('/rpc/$name', params, schema: schema);
    return rows.isEmpty ? null : rows.first;
  }

  Uri _uri(String path, [Map<String, Object?> query = const {}]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    final queryParameters = <String, String>{};
    for (final entry in query.entries) {
      final value = entry.value;
      if (value != null && value.toString().isNotEmpty) {
        queryParameters[entry.key] = value.toString();
      }
    }
    return queryParameters.isEmpty ? uri : uri.replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers(String schema, {String? prefer}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Profile': schema,
      'Content-Profile': schema,
      if (prefer != null) 'Prefer': prefer,
    };
  }

  Object? _decode(http.Response response, String method, String path) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        '$method $path basarisiz: ${response.body}',
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}
