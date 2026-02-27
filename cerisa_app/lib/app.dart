import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/core/services/storage_service.dart';

/// Widget raíz de la aplicación Cerisa.
///
/// Configura [MaterialApp] con:
/// - Tema claro y oscuro definidos en [AppTheme].
/// - Sistema de rutas con nombre gestionado por [AppRoutes].
/// - Auto-login: determina la ruta inicial según si el usuario
///   tiene una sesión activa almacenada en [StorageService].
class CerisaApp extends StatelessWidget {
  /// Constructor constante del widget raíz.
  const CerisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Leer el servicio de almacenamiento para verificar sesión activa
    final storage = context.read<StorageService>();

    // Si hay token almacenado, ir al home; de lo contrario, mostrar login
    final initialRoute = storage.isLoggedIn ? AppRoutes.home : AppRoutes.login;

    return MaterialApp(
      title: 'Cerisa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Forzar tema claro por defecto
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
