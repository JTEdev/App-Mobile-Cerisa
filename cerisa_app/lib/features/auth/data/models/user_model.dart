/// Modelo de datos que representa un usuario del sistema.
///
/// Mapea la estructura JSON devuelta por el API backend.
/// Contiene los datos básicos del usuario: identificador,
/// correo, nombre y rol.
class UserModel {
  /// Identificador único del usuario en la base de datos.
  final int id;

  /// Correo electrónico del usuario (usado para login).
  final String email;

  /// Nombre completo del usuario.
  final String nombre;

  /// Rol del usuario en el sistema (ej: 'ADMIN', 'CLIENTE').
  final String rol;

  /// Constructor del modelo de usuario.
  UserModel({required this.id, required this.email, required this.nombre, required this.rol});

  /// Crea una instancia de [UserModel] a partir de un mapa JSON.
  ///
  /// Se usa para deserializar la respuesta del API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
    );
  }

  /// Convierte el modelo a un mapa JSON.
  ///
  /// Se usa para serializar y enviar datos al API.
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'nombre': nombre, 'rol': rol};
  }
}
