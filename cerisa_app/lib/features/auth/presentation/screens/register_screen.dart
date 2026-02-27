import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';

/// Pantalla de registro de nuevo usuario.
///
/// Diseño consistente con el login: tonos cálidos café/beige,
/// campos con estilo card suave y botón marrón. Permite crear
/// una cuenta con nombre, correo, contraseña y confirmación.
class RegisterScreen extends StatefulWidget {
  /// Constructor constante.
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// Estado de [RegisterScreen] que gestiona los controladores del formulario.
class _RegisterScreenState extends State<RegisterScreen> {
  /// Clave global para validar el formulario de registro.
  final _formKey = GlobalKey<FormState>();

  /// Controlador para el campo de nombre completo.
  final _nombreController = TextEditingController();

  /// Controlador para el campo de correo electrónico.
  final _emailController = TextEditingController();

  /// Controlador para el campo de contraseña.
  final _passwordController = TextEditingController();

  /// Controlador para el campo de confirmación de contraseña.
  final _confirmPasswordController = TextEditingController();

  /// Controla la visibilidad de la contraseña.
  bool _obscurePassword = true;

  /// Controla la visibilidad de la confirmación de contraseña.
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Maneja el evento de registro de cuenta.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nombreController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado visual
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: const Icon(Icons.person_add_rounded, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Únete a Cerisa',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Crea tu cuenta para empezar',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de nombre completo
                _buildInputField(
                  controller: _nombreController,
                  hintText: 'Nombre completo',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 16),

                // Campo de correo electrónico
                _buildInputField(
                  controller: _emailController,
                  hintText: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese su correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                _buildInputField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese su contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de confirmación de contraseña
                _buildInputField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmar contraseña',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Botón de registro
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'REGISTRARSE',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Enlace para ir a login
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        children: const [
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye un campo de texto con estilo card suave (elevación, bordes redondeados).
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
