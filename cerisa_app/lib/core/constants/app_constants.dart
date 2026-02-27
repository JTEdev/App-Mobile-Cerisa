/// Constantes generales de la aplicación Cerisa.
///
/// Define cadenas reutilizadas en toda la app, como el nombre
/// de la aplicación, versión y claves para SharedPreferences.
class AppConstants {
  /// Constructor privado para evitar instanciación.
  AppConstants._();

  /// Nombre de la aplicación mostrado en la UI.
  static const String appName = 'Cerisa';

  /// Versión actual de la aplicación.
  static const String appVersion = '1.0.0';

  /// Clave de SharedPreferences para almacenar el token JWT.
  static const String tokenKey = 'auth_token';

  /// Clave de SharedPreferences para almacenar el refresh token.
  static const String refreshTokenKey = 'refresh_token';

  /// Clave de SharedPreferences para almacenar los datos del usuario.
  static const String userKey = 'user_data';
}
