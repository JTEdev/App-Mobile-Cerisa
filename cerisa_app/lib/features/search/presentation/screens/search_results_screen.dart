import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:cerisa_app/features/favorites/presentation/providers/favorites_provider.dart';

/// Argumentos para la pantalla de resultados de búsqueda.
class SearchResultsArgs {
  final String? query;
  final String? category;
  final double priceMin;
  final double priceMax;

  const SearchResultsArgs({this.query, this.category, this.priceMin = 0, this.priceMax = 500});
}

/// Pantalla que muestra los resultados filtrados de la búsqueda.
///
/// Recibe los filtros aplicados como argumentos y muestra los productos
/// que coinciden en un grid de 2 columnas con diseño e-commerce.
class SearchResultsScreen extends StatelessWidget {
  final SearchResultsArgs args;

  const SearchResultsScreen({super.key, required this.args});

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    return products.where((p) {
      // Filtro por texto
      if (args.query != null && args.query!.isNotEmpty) {
        final q = args.query!.toLowerCase();
        final nombre = p.nombre.toLowerCase();
        final desc = (p.descripcion ?? '').toLowerCase();
        final cat = (p.categoria ?? '').toLowerCase();
        if (!nombre.contains(q) && !desc.contains(q) && !cat.contains(q)) {
          return false;
        }
      }

      // Filtro por categoría
      if (args.category != null) {
        final cat = (p.categoria ?? '').toLowerCase();
        if (!cat.contains(args.category!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por precio
      if (p.precio < args.priceMin || p.precio > args.priceMax) {
        return false;
      }

      return true;
    }).toList();
  }

  String _buildTitle() {
    if (args.query != null && args.query!.isNotEmpty) {
      return '"${args.query}"';
    }
    if (args.category != null) {
      return args.category!;
    }
    return 'Resultados';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior ──
            _buildTopBar(context),

            // ── Contenido ──
            Expanded(
              child: Consumer<CatalogProvider>(
                builder: (context, catalog, _) {
                  if (catalog.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final results = _filterProducts(catalog.products);

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 72, color: AppColors.divider),
                          const SizedBox(height: 16),
                          const Text(
                            'No se encontraron productos',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Intenta con otros filtros o términos',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Volver a buscar',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info de resultados
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Text(
                          '${results.length} producto${results.length == 1 ? '' : 's'} encontrado${results.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Grid de productos
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return _ResultProductCard(product: results[index]);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          // Botón de retroceder
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          // Título dinámico
          Expanded(
            child: Text(
              _buildTitle(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Ícono de filtro para volver a buscar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de producto para los resultados de búsqueda.
class _ResultProductCard extends StatelessWidget {
  final ProductModel product;
  const _ResultProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(product.id);

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
            // Imagen con favorito
            Stack(
              children: [
                Container(
                  height: 140,
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
                        size: 16,
                        color: isFav ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                // Badge de stock bajo
                if (product.stock == 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        'Agotado',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            // Info del producto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      product.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
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
                        if (product.stock > 0)
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
