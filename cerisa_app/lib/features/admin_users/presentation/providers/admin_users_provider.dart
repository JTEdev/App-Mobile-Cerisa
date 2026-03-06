import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';

/// Modelo de datos que representa a un usuario del sistema.
///
/// Se puebla desde la respuesta JSON del endpoint GET /api/users.
/// Contiene los datos públicos del usuario (sin contraseña).
class UserModel {
  /// Identificador único del usuario.
  final int id;

  /// Nombre completo del usuario.
  final String nombre;

  /// Dirección de correo electrónico.
  final String email;

  /// Rol del usuario en el sistema (ADMIN o CLIENTE).
  String rol;

  /// Número de teléfono (opcional).
  final String? telefono;

  /// Fecha de registro del usuario (formato ISO).
  final String? creadoEn;

  /// Constructor del modelo de usuario.
  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.creadoEn,
  });

  /// Crea una instancia de [UserModel] a partir de un mapa JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      telefono: json['telefono'] as String?,
      creadoEn: json['creadoEn'] as String?,
    );
  }
}

/// Provider para la gestión de usuarios del panel de administración.
///
/// Permite listar todos los usuarios, cambiar roles y eliminar usuarios.
/// Se comunica con los endpoints `/api/users` del backend Spring Boot.
/// Utiliza [ChangeNotifier] para notificar cambios a la UI.
class AdminUsersProvider extends ChangeNotifier {
  /// Servicio HTTP para realizar las solicitudes al backend.
  final ApiService _api;

  /// Lista de usuarios cargados desde el backend.
  List<UserModel> _users = [];

  /// Indica si se está realizando una operación de carga.
  bool _isLoading = false;

  /// Mensaje de error de la última operación fallida (null si no hay error).
  String? _error;

  /// Crea una instancia de [AdminUsersProvider] con el [ApiService] proporcionado.
  AdminUsersProvider(this._api);

  /// Lista actual de usuarios.
  List<UserModel> get users => _users;

  /// Estado de carga actual.
  bool get isLoading => _isLoading;

  /// Mensaje de error actual (null si no hay error).
  String? get error => _error;

  /// Carga la lista de todos los usuarios desde el backend.
  ///
  /// Llama a GET /api/users con autenticación JWT.
  /// Actualiza [users], [isLoading] y [error] según el resultado.
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/users', auth: true);
      _users = list.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el rol de un usuario específico.
  ///
  /// Llama a PUT /api/users/{id}/role con el nuevo rol.
  /// Si es exitoso, actualiza el modelo local y notifica los listeners.
  ///
  /// [userId] es el ID del usuario a actualizar.
  /// [newRole] debe ser "ADMIN" o "CLIENTE".
  /// Retorna `true` si la operación fue exitosa, `false` en caso de error.
  Future<bool> updateUserRole(int userId, String newRole) async {
    try {
      await _api.put('/users/$userId/role', {'rol': newRole}, auth: true);
      // Actualizar el modelo local sin recargar toda la lista
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index].rol = newRole;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Elimina un usuario del sistema.
  ///
  /// Llama a DELETE /api/users/{id} con autenticación.
  /// Si es exitoso, remueve el usuario de la lista local.
  ///
  /// [userId] es el ID del usuario a eliminar.
  /// Retorna `true` si la operación fue exitosa, `false` en caso de error.
  Future<bool> deleteUser(int userId) async {
    try {
      await _api.delete('/users/$userId', auth: true);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Crea un nuevo cliente desde el panel de administración.
  ///
  /// Llama a POST /api/users con los datos del nuevo cliente.
  /// Retorna `true` si la creación fue exitosa.
  Future<bool> createClient(Map<String, dynamic> data) async {
    try {
      await _api.post('/users', data, auth: true);
      await loadUsers();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Actualiza los datos de un cliente existente.
  ///
  /// Llama a PUT /api/users/{id} con los datos actualizados.
  /// Retorna `true` si la actualización fue exitosa.
  Future<bool> updateClient(int userId, Map<String, dynamic> data) async {
    try {
      await _api.put('/users/$userId', data, auth: true);
      await loadUsers();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
