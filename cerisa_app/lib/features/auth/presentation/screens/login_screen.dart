import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';

/// Pantalla de inicio de sesión de la aplicación Cerisa.
///
/// Diseño cálido con tonos café/beige siguiendo la identidad visual
/// de la marca. Incluye logo con decoraciones doradas, campos con
/// estilo card suave y botón principal marrón.
class LoginScreen extends StatefulWidget {
  /// Constructor constante.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Estado de [LoginScreen] que gestiona los controladores del formulario.
class _LoginScreenState extends State<LoginScreen> {
  /// Clave global para validar el formulario de login.
  final _formKey = GlobalKey<FormState>();

  /// Controlador para el campo de correo electrónico.
  final _emailController = TextEditingController();

  /// Controlador para el campo de contraseña.
  final _passwordController = TextEditingController();

  /// Controla la visibilidad de la contraseña (mostrar/ocultar).
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Maneja el evento de inicio de sesión.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailController.text.trim(), _passwordController.text);

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Logo de la marca
                  Center(child: _buildLogo()),
                  const SizedBox(height: 14),
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo de correo electrónico con estilo card suave
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Usuario',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese su correo';
                      if (!value.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña con estilo card suave
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
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese su contraseña';
                      if (value.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón "INGRESAR >" con indicador de carga
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleLogin,
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'INGRESAR',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Enlace para crear cuenta nueva
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: RichText(
                        text: TextSpan(
                          text: '¿No tienes cuenta? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          children: const [
                            TextSpan(
                              text: 'Crear una cuenta nueva',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el logo usando la imagen Logo main.jpg.
  Widget _buildLogo() {
    return Container(
      width: 240,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EA),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/images/logo_main.jpg', fit: BoxFit.contain),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.55), fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }
}
