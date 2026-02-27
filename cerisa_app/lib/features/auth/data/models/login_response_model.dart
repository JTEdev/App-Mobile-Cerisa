/// Modelo de la respuesta del endpoint de login.
///
/// Contiene el token JWT, su tipo (Bearer), el correo electrónico
/// y el rol del usuario autenticado. Se usa para procesar la
/// respuesta exitosa de `/auth/login`.
class LoginResponseModel {
  /// Token JWT para autenticar solicitudes posteriores.
  final String token;

  /// Tipo de token (generalmente 'Bearer').
  final String type;

  /// Correo electrónico del usuario autenticado.
  final String email;

  /// Rol del usuario autenticado (ej: 'ADMIN', 'CLIENTE').
  final String rol;

  /// Constructor del modelo de respuesta de login.
  LoginResponseModel({required this.token, required this.type, required this.email, required this.rol});

  /// Crea una instancia a partir de un mapa JSON del API.
  ///
  /// Si el campo 'type' no está presente, usa 'Bearer' por defecto.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      email: json['email'] as String,
      rol: json['rol'] as String,
    );
  }
}
