import 'package:shared_preferences/shared_preferences.dart';
import 'package:cerisa_app/core/constants/app_constants.dart';

/// Servicio de almacenamiento local basado en SharedPreferences.
///
/// Gestiona la persistencia del token JWT y los datos básicos del
/// usuario (email, nombre, rol) en el almacenamiento local del
/// dispositivo. Es inyectado como dependencia en toda la app.
class StorageService {
  /// Instancia de SharedPreferences (se inicializa en [init]).
  SharedPreferences? _prefs;

  /// Inicializa SharedPreferences. Debe llamarse antes de usar el servicio.
  ///
  /// Se invoca en [main()] antes de lanzar la aplicación.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Token JWT ───────────────────────────────────────

  /// Obtiene el token JWT almacenado, o `null` si no existe.
  String? get token => _prefs?.getString(AppConstants.tokenKey);

  /// Guarda el token JWT en el almacenamiento local.
  Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  /// Elimina el token JWT del almacenamiento local.
  Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.tokenKey);
  }

  /// Indica si hay una sesión activa (token presente y no vacío).
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  // ─── Datos del usuario ───────────────────────────────

  /// Email del usuario almacenado localmente.
  String? get userEmail => _prefs?.getString('user_email');

  /// Nombre del usuario almacenado localmente.
  String? get userName => _prefs?.getString('user_name');

  /// Rol del usuario almacenado localmente (ej: 'ADMIN', 'CLIENTE').
  String? get userRole => _prefs?.getString('user_role');

  /// Guarda los datos básicos del usuario en SharedPreferences.
  ///
  /// Se llama después de un login o registro exitoso.
  Future<void> saveUser({required String email, required String nombre, required String rol}) async {
    await _prefs?.setString('user_email', email);
    await _prefs?.setString('user_name', nombre);
    await _prefs?.setString('user_role', rol);
  }

  /// Limpia todos los datos de SharedPreferences (logout completo).
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
