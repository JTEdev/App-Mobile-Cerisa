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

  /// Pantallas para usuarios con rol CLIENTE.
  static const List<Widget> _clientScreens = [
    CatalogScreen(), // Pestaña 0: Inicio / Catálogo rediseñado
    SearchScreen(), // Pestaña 1: Búsqueda de productos
    CartScreen(), // Pestaña 2: Carrito de compras
    FavoritesScreen(), // Pestaña 3: Productos favoritos
    ProfileScreen(), // Pestaña 4: Perfil y configuración
  ];

  /// Pantallas para usuarios con rol ADMIN.
  static const List<Widget> _adminScreens = [
    CatalogScreen(), // Pestaña 0: Catálogo de productos
    CartScreen(), // Pestaña 1: Carrito de compras
    MyOrdersScreen(), // Pestaña 2: Gestión de pedidos
    ProfileScreen(), // Pestaña 3: Perfil y administración
  ];

  /// Destinos de navegación para ADMIN.
  static const List<NavigationDestination> _adminDestinations = [
    NavigationDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: 'Catálogo',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: 'Carrito',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Pedidos',
    ),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final screens = isAdmin ? _adminScreens : _clientScreens;

    // Asegurar que el índice sea válido al cambiar de rol
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      // IndexedStack mantiene todas las pantallas en memoria
      // para preservar su estado al cambiar de pestaña
      body: IndexedStack(index: _currentIndex, children: screens),
      // Barra de navegación inferior
      bottomNavigationBar: isAdmin
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: _adminDestinations,
            )
          : _buildClientNavBar(),
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

  /// Construye un ítem individual de la barra de navegación.
  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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
      onTap: () => setState(() => _currentIndex = index),
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
