import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:cerisa_app/features/favorites/presentation/providers/favorites_provider.dart';

/// Pantalla principal del catálogo con diseño tipo e-commerce profesional.
///
/// Incluye: barra superior con título e íconos, barra de búsqueda,
/// filtros de categoría, banner destacado, secciones "Nuevos" y
/// "Más Vendidos" con tarjetas de producto interactivas.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Popular';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CatalogProvider>().loadProducts();
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  /// Obtiene las categorías únicas de los productos.
  List<String> _getCategories(List<ProductModel> products) {
    final cats = <String>{'Popular'};
    for (final p in products) {
      if (p.categoria != null && p.categoria!.isNotEmpty) {
        cats.add(p.categoria!);
      }
    }
    return cats.toList();
  }

  /// Filtra productos según la categoría seleccionada.
  List<ProductModel> _filterProducts(List<ProductModel> products) {
    if (_selectedCategory == 'Popular') return products;
    return products.where((p) => p.categoria == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CatalogProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const AppLoadingIndicator();
            if (provider.error != null) {
              return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadProducts());
            }

            final allProducts = provider.products;
            final filtered = _filterProducts(allProducts);
            final categories = _getCategories(allProducts);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.loadProducts(),
              child: CustomScrollView(
                slivers: [
                  // ── Barra superior ──
                  SliverToBoxAdapter(child: _buildTopBar(context)),

                  // ── Barra de búsqueda ──
                  SliverToBoxAdapter(child: _buildSearchBar(context)),

                  // ── Chips de categoría ──
                  SliverToBoxAdapter(child: _buildCategoryChips(categories)),

                  // ── Banner destacado ──
                  SliverToBoxAdapter(child: _buildFeaturedBanner(context)),

                  // ── Sección "Nuevos" (scroll horizontal) ──
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'Nuevos',
                      onSeeAll: () => Navigator.pushNamed(context, AppRoutes.search),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildNewArrivals(filtered)),

                  // ── Sección "Más Vendidos" (grid 2 columnas) ──
                  SliverToBoxAdapter(child: _buildSectionHeader('Más Vendidos', showFilter: true)),
                  _buildBestSellersGrid(filtered),

                  // Espacio inferior
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Barra superior con menú hamburguesa, título y acciones.
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Menú hamburguesa (decorativo, puede abrir drawer futuro)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          // Título "Cerisa"
          const Text(
            'Cerisa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Campana de notificaciones
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          // Carrito con badge de cantidad
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Barra de búsqueda con ícono de filtro.
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.search);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textSecondary.withValues(alpha: 0.6), size: 22),
              const SizedBox(width: 12),
              Text(
                'Buscar productos...',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chips horizontales de filtro por categoría.
  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat == 'Popular')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.accent,
                      ),
                    ),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Banner destacado con imagen decorativa.
  Widget _buildFeaturedBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, Color(0xFF8B6944)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Decoración de fondo (círculos abstractos)
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            // Ícono decorativo a la derecha
            Positioned(
              right: 20,
              top: 25,
              child: Icon(Icons.spa_rounded, size: 90, color: Colors.white.withValues(alpha: 0.15)),
            ),
            // Contenido del banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge DESTACADO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      'DESTACADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Colección\nOtoño 2026',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  // Botón "Ver Colección"
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                      child: const Text(
                        'Ver Colección',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Encabezado de sección con título y "Ver todo" o filtro.
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll, bool showFilter = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Row(
                children: [
                  Text(
                    'Ver todo',
                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accent),
                ],
              ),
            ),
          if (showFilter)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  /// Sección "Nuevos" — scroll horizontal de tarjetas tall con corazón.
  Widget _buildNewArrivals(List<ProductModel> products) {
    // Tomar los últimos productos como "nuevos" (máx 8)
    final newProducts = products.length > 8 ? products.sublist(products.length - 8) : products;

    if (newProducts.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text('No hay productos en esta categoría', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: newProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _NewArrivalCard(product: newProducts[index]);
        },
      ),
    );
  }

  /// Grid "Más Vendidos" — 2 columnas con badge HOT y estrellas.
  SliverPadding _buildBestSellersGrid(List<ProductModel> products) {
    // Primeros productos como "best sellers"
    final bestSellers = products.length > 6 ? products.sublist(0, 6) : products;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: bestSellers.isEmpty
          ? const SliverToBoxAdapter(
              child: SizedBox(
                height: 80,
                child: Center(
                  child: Text('No hay productos en esta categoría', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            )
          : SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _BestSellerCard(product: bestSellers[index]),
                childCount: bestSellers.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TARJETA "NUEVOS" — Scroll horizontal con corazón de favorito
// ═══════════════════════════════════════════════════════════════

class _NewArrivalCard extends StatelessWidget {
  final ProductModel product;
  const _NewArrivalCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(product.id);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id),
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con botón de favorito
            Stack(
              children: [
                Container(
                  height: 155,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0EA),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: product.imagenUrl != null
                        ? Image.network(
                            product.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.inventory_2, size: 44, color: AppColors.divider)),
                          )
                        : const Center(child: Icon(Icons.inventory_2, size: 44, color: AppColors.divider)),
                  ),
                ),
                // Corazón de favorito
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => favs.toggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isFav ? AppColors.accent : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFav ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info del producto
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.categoria ?? 'Cerisa',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'S/ ${product.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TARJETA "MÁS VENDIDOS" — Grid con badge HOT, estrellas y botón +
// ═══════════════════════════════════════════════════════════════

class _BestSellerCard extends StatelessWidget {
  final ProductModel product;
  const _BestSellerCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Rating simulado basado en el ID del producto para consistencia
    final rating = 3.5 + (product.id % 15) * 0.1;
    final isHot = product.stock > 10;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con badge HOT
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F0EA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: product.imagenUrl != null
                        ? Image.network(
                            product.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.inventory_2, size: 40, color: AppColors.divider)),
                          )
                        : const Center(child: Icon(Icons.inventory_2, size: 40, color: AppColors.divider)),
                  ),
                ),
                // Badge HOT
                if (isHot)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info con rating y botón +
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estrellas de rating
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < rating.floor()
                                ? Icons.star_rounded
                                : (i < rating.ceil() ? Icons.star_half_rounded : Icons.star_outline_rounded),
                            size: 14,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Nombre del producto
                    Text(
                      product.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.categoria ?? 'Cerisa',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    // Precio y botón agregar al carrito
                    Row(
                      children: [
                        Text(
                          'S/ ${product.precio.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.accent),
                        ),
                        const Spacer(),
                        // Botón circular "+"
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.nombre} agregado al carrito'),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
