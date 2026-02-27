import 'package:flutter/material.dart';

/// Paleta de colores de la marca Cerisa.
///
/// Centraliza todos los colores usados en la aplicación para
/// mantener consistencia visual. Basada en tonos cálidos café/beige
/// inspirados en la identidad visual de Cerisa.
class AppColors {
  /// Constructor privado para evitar instanciación.
  AppColors._();

  /// Color primario de la marca (marrón cálido).
  static const Color primary = Color(0xFF7B5B3A);

  /// Variante oscura del color primario.
  static const Color primaryDark = Color(0xFF5D3F24);

  /// Color de acento / secundario (dorado cálido).
  static const Color accent = Color(0xFFCBA054);

  /// Color de fondo general de la app (beige claro).
  static const Color background = Color(0xFFF5EDE3);

  /// Color de superficie para tarjetas y contenedores (crema).
  static const Color surface = Color(0xFFFFFBF5);

  /// Color para indicar errores.
  static const Color error = Color(0xFFD32F2F);

  /// Color para indicar éxito / operaciones correctas.
  static const Color success = Color(0xFF388E3C);

  /// Color principal para textos.
  static const Color textPrimary = Color(0xFF3E2C1C);

  /// Color secundario para textos de menor jerarquía.
  static const Color textSecondary = Color(0xFF8C7B6B);

  /// Color para líneas divisoras.
  static const Color divider = Color(0xFFD4C4B0);

  /// Color de fondo para inputs/textfields.
  static const Color inputFill = Color(0xFFF0E8DF);

  /// Color del borde de inputs.
  static const Color inputBorder = Color(0xFFD4C4B0);
}

/// Configuración del tema visual de la aplicación Cerisa.
///
/// Define los temas claro ([lightTheme]) y oscuro ([darkTheme])
/// utilizando Material 3. Colores cálidos café/beige siguiendo
/// la identidad visual de la marca.
class AppTheme {
  /// Constructor privado para evitar instanciación.
  AppTheme._();

  /// Tema claro principal de la aplicación.
  ///
  /// Usa Material 3 con [AppColors.primary] como color semilla.
  /// Personaliza AppBar, botones e inputs con tonos cálidos.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.inputBorder.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.inputBorder.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
        prefixIconColor: AppColors.textSecondary,
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return const TextStyle(color: AppColors.textSecondary, fontSize: 12);
        }),
      ),
    );
  }

  /// Tema oscuro de la aplicación.
  ///
  /// Utiliza Material 3 con el mismo color semilla pero en modo oscuro.
  /// Tonos cálidos oscuros para mantener la identidad visual.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: const Color(0xFFD4A574),
        secondary: AppColors.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2520),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4A574), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A574),
          foregroundColor: const Color(0xFF2C2520),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
