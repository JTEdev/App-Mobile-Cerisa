/// Contrato abstracto (interfaz) del repositorio de autenticación.
///
/// Define las operaciones que cualquier implementación del repositorio
/// de autenticación debe proveer. Sigue el principio de inversión de
/// dependencias (Clean Architecture) para desacoplar la capa de dominio
/// de la implementación concreta (API, Firebase, etc.).
abstract class AuthRepository {
  /// Inicia sesión con [email] y [password].
  Future<void> login(String email, String password);

  /// Registra un nuevo usuario con los datos proporcionados.
  Future<void> register({required String nombre, required String email, required String password});

  /// Cierra la sesión del usuario actual.
  Future<void> logout();

  /// Verifica si hay una sesión activa.
  Future<bool> isLoggedIn();
}
