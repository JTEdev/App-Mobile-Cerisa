import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cerisa_app/core/constants/api_constants.dart';
import 'package:cerisa_app/core/services/storage_service.dart';

/// Servicio cliente HTTP para comunicarse con el API backend de Cerisa.
///
/// Encapsula las operaciones GET, POST, PUT y DELETE, inyectando
/// automáticamente el token JWT en las cabeceras cuando se requiere
/// autenticación. Utiliza el paquete `http` para las solicitudes.
class ApiService {
  /// Servicio de almacenamiento local para obtener el token JWT.
  final StorageService _storage;

  /// Crea una instancia de [ApiService] con el [StorageService] proporcionado.
  ApiService(this._storage);

  /// Construye las cabeceras HTTP para cada solicitud.
  ///
  /// Siempre incluye `Content-Type: application/json`.
  /// Si [auth] es `true`, añade la cabecera `Authorization: Bearer <token>`
  /// usando el token almacenado o el [token] proporcionado explícitamente.
  Map<String, String> _headers({bool auth = false, String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = token ?? _storage.token;
      if (t != null) headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  /// Realiza una solicitud GET y devuelve el cuerpo como [Map].
  ///
  /// [path] es la ruta relativa al [ApiConstants.baseUrl].
  /// Si [auth] es `true`, incluye el token JWT en las cabeceras.
  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}$path'), headers: _headers(auth: auth));
    return _handleResponse(response);
  }

  /// Realiza una solicitud GET y devuelve el cuerpo como [List].
  ///
  /// Útil para endpoints que devuelven arreglos JSON (ej: lista de productos).
  /// Lanza una excepción si el código de estado no es exitoso (2xx).
  Future<List<dynamic>> getList(String path, {bool auth = false}) async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}$path'), headers: _headers(auth: auth));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw _parseError(response);
  }

  /// Realiza una solicitud POST con el [body] proporcionado.
  ///
  /// El cuerpo se serializa a JSON automáticamente.
  /// Devuelve la respuesta decodificada como [Map].
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Realiza una solicitud PUT con el [body] proporcionado.
  ///
  /// Se usa para actualizar recursos existentes en el backend.
  /// Devuelve la respuesta decodificada como [Map].
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Realiza una solicitud DELETE al [path] especificado.
  ///
  /// Por defecto requiere autenticación ([auth] = true).
  /// Lanza una excepción si el código de estado indica error (≥ 300).
  Future<void> delete(String path, {bool auth = true}) async {
    final response = await http.delete(Uri.parse('${ApiConstants.baseUrl}$path'), headers: _headers(auth: auth));
    if (response.statusCode >= 300) throw _parseError(response);
  }

  /// Procesa la respuesta HTTP y devuelve el cuerpo decodificado.
  ///
  /// Si el código de estado es exitoso (2xx), decodifica el JSON.
  /// Si el cuerpo está vacío, devuelve un mapa vacío.
  /// En caso de error, lanza la excepción correspondiente.
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw _parseError(response);
  }

  /// Extrae el mensaje de error del cuerpo de la respuesta HTTP.
  ///
  /// Intenta decodificar el campo 'mensaje' del JSON de error.
  /// Si no es posible, devuelve un mensaje genérico con el código de estado.
  Exception _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return Exception(body['mensaje'] ?? 'Error ${response.statusCode}');
    } catch (_) {
      return Exception('Error ${response.statusCode}');
    }
  }
}
