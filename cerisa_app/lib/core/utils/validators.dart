/// Validadores reutilizables para campos de formulario.
///
/// Cada método estático recibe el valor del campo y devuelve
/// `null` si es válido, o un mensaje de error en español si no.
/// Se usan con la propiedad `validator` de [TextFormField].
class Validators {
  /// Constructor privado para evitar instanciación.
  Validators._();

  /// Valida que el [value] sea un correo electrónico válido.
  ///
  /// Verifica que no esté vacío y que cumpla con el formato básico
  /// de email usando una expresión regular.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El correo es obligatorio';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Ingrese un correo válido';
    return null;
  }

  /// Valida que la contraseña no esté vacía y tenga al menos 6 caracteres.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  /// Valida que un campo requerido no esté vacío.
  ///
  /// [field] es el nombre del campo para el mensaje de error
  /// (por defecto 'Este campo').
  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  /// Valida que el número de teléfono no esté vacío y tenga al menos 9 dígitos.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es obligatorio';
    if (value.length < 9) return 'Ingrese un teléfono válido';
    return null;
  }
}
