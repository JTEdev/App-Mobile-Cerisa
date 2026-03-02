import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';

/// Pantalla de productos favoritos estilo e-commerce.
///
/// Muestra los favoritos en un grid de 2 columnas con:
/// - Título "Mis Favoritos" en color accent
/// - Chips de categoría para filtrar
/// - Tarjetas de producto con imagen, favorito, nombre, categoría y precio
/// - Botón "+" para agregar al carrito
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  /// Obtiene las categorías únicas de los favoritos.
  List<String> _getCategories(List<ProductModel> products) {
    final cats = <String>{'Todos'};
    for (final p in products) {
      if (p.categoria != null && p.categoria!.isNotEmpty) {
        cats.add(p.categoria!);
      }
    }
    return cats.toList();
  }

  /// Filtra los productos según la categoría seleccionada.
  List<ProductModel> _filterByCategory(List<ProductModel> products) {
    if (_selectedFilter == 'Todos') return products;
    return products.where((p) => (p.categoria ?? '').toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<FavoritesProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Encabezado ──
                _buildHeader(context),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: AppColors.divider.withValues(alpha: 0.5), height: 1),
                ),
                const SizedBox(height: 12),

                // ── Chips de categoría ──
                if (!provider.isLoading && provider.favorites.isNotEmpty) _buildCategoryChips(provider.favorites),

                // ── Contenido principal ──
                Expanded(child: _buildContent(provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Encabezado: titulo "Mis Favoritos" + ícono filtro.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mis Favoritos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.accent, letterSpacing: -0.5),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.textPrimary, size: 22),
              onPressed: () {
                context.read<FavoritesProvider>().loadFavorites(force: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Chips de filtro por categoría.
  Widget _buildCategoryChips(List<ProductModel> products) {
    final categories = _getCategories(products);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedFilter == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Contenido principal: loading, error, vacío o grid.
  Widget _buildContent(FavoritesProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: AppColors.accent.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => provider.loadFavorites(force: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.divider),
              const SizedBox(height: 20),
              const Text(
                'No tienes favoritos aún',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text(
                'Explora el catálogo y marca tus\nproductos preferidos con el corazón',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filterByCategory(provider.favorites);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: AppColors.divider),
            const SizedBox(height: 12),
            Text(
              'No hay favoritos en "$_selectedFilter"',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _FavoriteProductCard(product: filtered[index]);
      },
    );
  }
}

/// Tarjeta de producto favorito estilo e-commerce.
class _FavoriteProductCard extends StatelessWidget {
  final ProductModel product;
  const _FavoriteProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(product.id);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen con botón favorito ──
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F0EA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: product.imagenUrl != null
                        ? Image.network(
                            product.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.inventory_2_rounded, size: 40, color: AppColors.divider),
                            ),
                          )
                        : const Center(child: Icon(Icons.inventory_2_rounded, size: 40, color: AppColors.divider)),
                  ),
                ),
                // Botón de favorito (corazón)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      favs.toggleFavorite(product.id);
                      if (isFav) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.nombre} quitado de favoritos'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            action: SnackBarAction(
                              label: 'Deshacer',
                              textColor: Colors.white,
                              onPressed: () => favs.addFavorite(product.id),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
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
            // ── Información del producto ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      product.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    // Categoría
                    Text(
                      product.categoria ?? 'Cerisa',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    // Precio y botón agregar
                    Row(
                      children: [
                        Text(
                          'S/ ${product.precio.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.accent),
                        ),
                        const Spacer(),
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
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.2),
                            ),
                            child: const Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
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
