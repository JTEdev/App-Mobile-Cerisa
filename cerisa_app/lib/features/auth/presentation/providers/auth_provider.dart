import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/core/services/storage_service.dart';

/// Provider que gestiona el estado de autenticación del usuario.
///
/// Maneja login, registro y logout, comunicando con el API backend
/// a través de [ApiService] y persistiendo la sesión con [StorageService].
/// Extiende [ChangeNotifier] para notificar a los widgets que escuchan
/// cambios en el estado de autenticación.
class AuthProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el API backend.
  final ApiService _api;

  /// Servicio de almacenamiento local para persistir token y datos de usuario.
  final StorageService _storage;

  /// Constructor que recibe las dependencias inyectadas.
  AuthProvider(this._api, this._storage);

  /// Indica si hay una operación de autenticación en curso.
  bool _isLoading = false;

  /// Mensaje de error de la última operación fallida, o `null` si no hay error.
  String? _error;

  /// Nombre del usuario en memoria (caché de la sesión actual).
  String? _userName;

  /// Email del usuario en memoria.
  String? _userEmail;

  /// Rol del usuario en memoria (ej: 'ADMIN', 'CLIENTE').
  String? _userRole;

  /// Getter: indica si hay una operación en curso.
  bool get isLoading => _isLoading;

  /// Getter: mensaje de error de la última operación.
  String? get error => _error;

  /// Getter: indica si el usuario tiene sesión activa.
  bool get isLoggedIn => _storage.isLoggedIn;

  /// Getter: nombre del usuario (memoria o almacenamiento local).
  String? get userName => _userName ?? _storage.userName;

  /// Getter: email del usuario (memoria o almacenamiento local).
  String? get userEmail => _userEmail ?? _storage.userEmail;

  /// Getter: rol del usuario (memoria o almacenamiento local).
  String? get userRole => _userRole ?? _storage.userRole;

  /// Getter: indica si el usuario tiene rol de administrador.
  bool get isAdmin => userRole == 'ADMIN';

  /// Inicia sesión con [email] y [password].
  ///
  /// Realiza un POST a `/auth/login` y, si es exitoso, almacena
  /// el token JWT y los datos del usuario localmente.
  /// Retorna `true` si el login fue exitoso, `false` si falló.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Enviar credenciales al endpoint de login
      final data = await _api.post('/auth/login', {'email': email, 'password': password});

      // Guardar token y datos del usuario en almacenamiento local
      await _storage.saveToken(data['token']);
      await _storage.saveUser(email: data['email'], nombre: data['nombre'], rol: data['rol']);

      // Actualizar caché en memoria
      _userName = data['nombre'];
      _userEmail = data['email'];
      _userRole = data['rol'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Limpiar el prefijo 'Exception: ' para un mensaje más limpio
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo usuario con [nombre], [email] y [password].
  ///
  /// Realiza un POST a `/auth/register`. Si es exitoso, aplica
  /// auto-login guardando el token y datos del nuevo usuario.
  /// Retorna `true` si el registro fue exitoso, `false` si falló.
  Future<bool> register(String nombre, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Enviar datos de registro al backend
      final data = await _api.post('/auth/register', {'nombre': nombre, 'email': email, 'password': password});

      // Auto-login: guardar token y datos del nuevo usuario
      await _storage.saveToken(data['token']);
      await _storage.saveUser(email: data['email'], nombre: data['nombre'], rol: data['rol']);

      // Actualizar caché en memoria
      _userName = data['nombre'];
      _userEmail = data['email'];
      _userRole = data['rol'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión del usuario.
  ///
  /// Limpia todos los datos de SharedPreferences y la caché en memoria.
  /// Los widgets deben redirigir al login después de llamar este método.
  Future<void> logout() async {
    await _storage.clearAll();
    _userName = null;
    _userEmail = null;
    _userRole = null;
    notifyListeners();
  }

  /// Limpia el mensaje de error actual.
  ///
  /// Útil para limpiar errores previos antes de un nuevo intento.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
