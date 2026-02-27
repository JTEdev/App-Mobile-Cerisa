/// Punto de entrada principal de la aplicación Cerisa.
///
/// Este archivo inicializa los servicios fundamentales (almacenamiento local
/// y cliente HTTP) y configura el árbol de providers con [MultiProvider]
/// para inyectar dependencias en toda la app mediante el patrón Provider.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/app.dart';
import 'package:cerisa_app/core/services/storage_service.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';
import 'package:cerisa_app/features/admin_reports/presentation/providers/reports_provider.dart';
import 'package:cerisa_app/features/admin_users/presentation/providers/admin_users_provider.dart';
import 'package:cerisa_app/features/favorites/presentation/providers/favorites_provider.dart';

/// Función principal que arranca la aplicación Flutter.
///
/// Realiza los siguientes pasos:
/// 1. Asegura la inicialización del binding de widgets.
/// 2. Inicializa [StorageService] (SharedPreferences) para persistencia local.
/// 3. Crea [ApiService] inyectándole el servicio de almacenamiento.
/// 4. Configura [MultiProvider] con todos los providers de la app.
/// 5. Lanza [CerisaApp] como widget raíz.
void main() async {
  // Necesario antes de usar plugins asíncronos en main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el servicio de almacenamiento local (SharedPreferences)
  final storage = StorageService();
  await storage.init();

  // Crear el servicio de API con inyección del storage para manejo de tokens
  final api = ApiService(storage);

  runApp(
    /// [MultiProvider] registra todos los providers en el árbol de widgets.
    /// Los servicios base (StorageService, ApiService) se proveen como
    /// Provider.value, mientras que los ChangeNotifierProvider gestionan
    /// el estado reactivo de cada módulo funcional.
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthProvider(api, storage)),
        ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
        ChangeNotifierProvider(create: (_) => CartProvider(api)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(api)),
        ChangeNotifierProvider(create: (_) => AdminProductsProvider(api)),
        ChangeNotifierProvider(create: (_) => ReportsProvider(api)),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider(api)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(api)),
      ],
      child: const CerisaApp(),
    ),
  );
}
