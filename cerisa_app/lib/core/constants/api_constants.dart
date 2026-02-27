/// Constantes de configuración de red y URLs del API backend.
///
/// Centraliza todas las URLs y tiempos de espera para las
/// llamadas HTTP al servidor Spring Boot. Modificar [baseUrl]
/// al desplegar en producción.
class ApiConstants {
  /// Constructor privado para evitar instanciación.
  ApiConstants._();

  /// URL base del API backend.
  /// En el emulador de Android, 10.0.2.2 redirige a localhost de la máquina host.
  /// Puerto 8081 corresponde al servidor Spring Boot.
  static const String baseUrl = 'http://10.0.2.2:8081/api'; // 10.0.2.2 = localhost desde el emulador Android

  /// Endpoint para iniciar sesión (POST).
  static const String loginEndpoint = '/auth/login';

  /// Endpoint para registrar un nuevo usuario (POST).
  static const String registerEndpoint = '/auth/register';

  /// Tiempo máximo de espera para establecer conexión con el servidor.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Tiempo máximo de espera para recibir la respuesta del servidor.
  static const Duration receiveTimeout = Duration(seconds: 15);
}
