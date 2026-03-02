import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:cerisa_app/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:cerisa_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:cerisa_app/features/search/presentation/screens/search_screen.dart';
import 'package:cerisa_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:cerisa_app/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:cerisa_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:cerisa_app/features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:cerisa_app/features/admin_orders/presentation/screens/admin_orders_screen.dart';

/// Pantalla principal de la aplicación con barra de navegación inferior.
///
/// Muestra diferentes pestañas según el rol del usuario:
/// - **Cliente**: Inicio, Buscar, Carrito, Favoritos, Perfil (5 tabs)
/// - **Admin**: Catálogo, Carrito, Pedidos, Perfil (4 tabs)
///
/// Usa [IndexedStack] para mantener el estado de cada pestaña al
/// cambiar entre ellas sin reconstruir los widgets.
class HomeScreen extends StatefulWidget {
  /// Constructor constante.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Estado de [HomeScreen] que gestiona la pestaña seleccionada.
class _HomeScreenState extends State<HomeScreen> {
  /// Índice de la pestaña actualmente seleccionada (0 = Inicio).
  int _currentIndex = 0;

  /// Construye la pantalla correspondiente al índice para CLIENTE.
  Widget _buildClientScreen(int index) {
    switch (index) {
      case 0:
        return const CatalogScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const CartScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const CatalogScreen();
    }
  }

  /// Construye la pantalla correspondiente al índice para ADMIN.
  Widget _buildAdminScreen(int index) {
    switch (index) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const CatalogScreen();
      case 2:
        return const AdminOrdersScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const AdminDashboardScreen();
    }
  }

  // (Admin nav bar is now custom, built inline below)

  @override
  Widget build(BuildContext context) {
    // Solo reconstruir cuando isAdmin cambie, no en cada notificación de AuthProvider
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);
    final maxIndex = isAdmin ? 3 : 4;

    // Asegurar que el índice sea válido al cambiar de rol
    if (_currentIndex > maxIndex) {
      _currentIndex = 0;
    }

    return Scaffold(
      // Solo construir UNA pantalla a la vez (no IndexedStack con todas)
      body: isAdmin ? _buildAdminScreen(_currentIndex) : _buildClientScreen(_currentIndex),
      // Barra de navegación inferior
      bottomNavigationBar: isAdmin ? _buildAdminNavBar() : _buildClientNavBar(),
    );
  }

  /// Barra de navegación personalizada para clientes con badge en carrito.
  Widget _buildClientNavBar() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
                  _buildNavItem(1, Icons.search_outlined, Icons.search_rounded, 'Buscar'),
                  _buildCartNavItem(2, cart.itemCount),
                  _buildNavItem(3, Icons.favorite_outline, Icons.favorite_rounded, 'Favoritos'),
                  _buildNavItem(4, Icons.person_outline, Icons.person_rounded, 'Perfil'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Barra de navegación personalizada para admin (INICIO, MERCADO, PEDIDOS, PERFIL).
  Widget _buildAdminNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'INICIO'),
              _buildNavItem(1, Icons.storefront_outlined, Icons.storefront, 'MERCADO'),
              _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long, 'PEDIDOS'),
              _buildNavItem(3, Icons.person_outline, Icons.person_rounded, 'PERFIL'),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un ítem individual de la barra de navegación.
  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;
      }),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el ítem de carrito con badge de cantidad.
  Widget _buildCartNavItem(int index, int itemCount) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;
      }),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 22,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Carrito',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
