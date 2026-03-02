import 'package:flutter/material.dart';
import 'package:cerisa_app/features/auth/presentation/screens/login_screen.dart';
import 'package:cerisa_app/features/auth/presentation/screens/register_screen.dart';
import 'package:cerisa_app/features/home/presentation/screens/home_screen.dart';
import 'package:cerisa_app/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:cerisa_app/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:cerisa_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:cerisa_app/features/cart/presentation/screens/checkout_screen.dart';
import 'package:cerisa_app/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:cerisa_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:cerisa_app/features/admin_products/presentation/screens/admin_products_screen.dart';
import 'package:cerisa_app/features/admin_stock/presentation/screens/admin_stock_screen.dart';
import 'package:cerisa_app/features/admin_orders/presentation/screens/admin_orders_screen.dart';
import 'package:cerisa_app/features/admin_reports/presentation/screens/admin_reports_screen.dart';
import 'package:cerisa_app/features/admin_users/presentation/screens/admin_users_screen.dart';
import 'package:cerisa_app/features/admin_sales/presentation/screens/register_sale_screen.dart';
import 'package:cerisa_app/features/admin_products/presentation/screens/edit_product_screen.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/search/presentation/screens/search_screen.dart';
import 'package:cerisa_app/features/search/presentation/screens/search_results_screen.dart';
import 'package:cerisa_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:cerisa_app/features/orders/presentation/screens/order_success_screen.dart';
import 'package:cerisa_app/features/orders/presentation/screens/order_tracking_screen.dart';

/// Sistema de rutas con nombre de la aplicación Cerisa.
///
/// Define todas las rutas (paths) como constantes estáticas y proporciona
/// un generador de rutas [generateRoute] que mapea cada nombre de ruta
/// a su respectiva pantalla (screen). Se usa con [MaterialApp.onGenerateRoute].
class AppRoutes {
  /// Constructor privado para evitar instanciación.
  AppRoutes._();

  // ─── Rutas del cliente ─────────────────────────────────────

  /// Ruta de la pantalla de splash / carga inicial.
  static const String splash = '/';

  /// Ruta de la pantalla de inicio de sesión.
  static const String login = '/login';

  /// Ruta de la pantalla de registro de nueva cuenta.
  static const String register = '/register';

  /// Ruta de la pantalla principal con barra de navegación inferior.
  static const String home = '/home';

  /// Ruta de la pantalla del catálogo de productos.
  static const String catalog = '/catalog';

  /// Ruta del detalle de un producto. Recibe [int] productId como argumento.
  static const String productDetail = '/catalog/detail';

  /// Ruta de la pantalla del carrito de compras.
  static const String cart = '/cart';

  /// Ruta de la pantalla de checkout (confirmar pedido).
  static const String checkout = '/checkout';

  /// Ruta de la pantalla de historial de pedidos del usuario.
  static const String orders = '/orders';

  /// Ruta de la pantalla de búsqueda de productos.
  static const String search = '/search';

  /// Ruta de la pantalla de resultados de búsqueda filtrados.
  static const String searchResults = '/search/results';

  /// Ruta de la pantalla de productos favoritos.
  static const String favorites = '/favorites';

  /// Ruta de la pantalla de rastreo de pedido.
  static const String orderTracking = '/order-tracking';

  /// Ruta de la pantalla de confirmación de pedido exitoso.
  static const String orderSuccess = '/order-success';

  /// Ruta de la pantalla de perfil del usuario.
  static const String profile = '/profile';

  // ─── Rutas de administración ───────────────────────────────

  /// Ruta de la pantalla de gestión de productos (CRUD).
  static const String adminProducts = '/admin/products';

  /// Ruta de la pantalla de gestión de stock.
  static const String adminStock = '/admin/stock';

  /// Ruta de la pantalla de gestión de pedidos (admin).
  static const String adminOrders = '/admin/orders';

  /// Ruta de la pantalla de reportes de ventas.
  static const String adminReports = '/admin/reports';

  /// Ruta de la pantalla de gestión de usuarios.
  static const String adminUsers = '/admin/users';

  /// Ruta de la pantalla de registro de venta directa.
  static const String registerSale = '/admin/register-sale';

  /// Ruta de la pantalla de edición de producto.
  static const String editProduct = '/admin/products/edit';

  /// Generador de rutas utilizado por [MaterialApp.onGenerateRoute].
  ///
  /// Recibe [RouteSettings] con el nombre de la ruta y argumentos opcionales,
  /// y devuelve la [MaterialPageRoute] correspondiente.
  /// Si la ruta no existe, muestra una pantalla de error con el nombre solicitado.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case catalog:
        return MaterialPageRoute(builder: (_) => const CatalogScreen());
      case productDetail:
        // Se espera recibir el ID del producto como argumento de tipo int
        final productId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId));
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case searchResults:
        final searchArgs = settings.arguments as SearchResultsArgs;
        return MaterialPageRoute(builder: (_) => SearchResultsScreen(args: searchArgs));
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case orderTracking:
        final trackOrder = settings.arguments as OrderModel;
        return MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: trackOrder));
      case orderSuccess:
        final successArgs = settings.arguments as OrderSuccessArgs;
        return MaterialPageRoute(builder: (_) => OrderSuccessScreen(args: successArgs));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case adminProducts:
        return MaterialPageRoute(builder: (_) => const AdminProductsScreen());
      case adminStock:
        return MaterialPageRoute(builder: (_) => const AdminStockScreen());
      case adminOrders:
        return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());
      case adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
      case registerSale:
        return MaterialPageRoute(builder: (_) => const RegisterSaleScreen());
      case editProduct:
        final editProductArg = settings.arguments as ProductModel?;
        return MaterialPageRoute(builder: (_) => EditProductScreen(product: editProductArg));
      default:
        // Ruta no registrada: mostrar pantalla de error
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('Ruta no encontrada: ${settings.name}'))),
        );
    }
  }
}
