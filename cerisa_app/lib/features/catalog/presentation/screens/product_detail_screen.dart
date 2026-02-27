import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';

/// Pantalla de detalle de un producto individual.
///
/// Muestra la imagen, nombre, precio, categoría, disponibilidad de stock
/// y descripción del producto. Incluye un botón fijo en la parte inferior
/// para agregar el producto al carrito de compras.
class ProductDetailScreen extends StatelessWidget {
  /// ID del producto a mostrar (recibido como argumento de navegación).
  final int productId;

  /// Constructor que requiere el [productId].
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // Obtener el producto del CatalogProvider por su ID
    final product = context.watch<CatalogProvider>().getById(productId);

    // Si el producto no se encuentra, mostrar mensaje de error
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Producto no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto o placeholder
            Container(
              width: double.infinity,
              height: 280,
              color: Colors.grey[200],
              child: product.imagenUrl != null
                  ? Image.network(
                      product.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.grey),
                    )
                  : const Icon(Icons.inventory_2, size: 80, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(product.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Precio del producto en soles
                  Text(
                    'S/ ${product.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chip de categoría (si existe)
                  if (product.categoria != null) Chip(label: Text(product.categoria!)),
                  const SizedBox(height: 8),

                  // Indicador de disponibilidad de stock
                  Row(
                    children: [
                      Icon(
                        product.stock > 0 ? Icons.check_circle : Icons.cancel,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.stock > 0 ? 'Disponible (${product.stock} en stock)' : 'Agotado',
                        style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Descripción del producto (si existe)
                  if (product.descripcion != null && product.descripcion!.isNotEmpty) ...[
                    const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(product.descripcion!, style: const TextStyle(height: 1.5)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // Botón fijo inferior para agregar al carrito
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            // Solo habilitado si hay stock disponible
            onPressed: product.stock > 0
                ? () {
                    // Agregar producto al carrito
                    context.read<CartProvider>().addToCart(product);
                    // Mostrar confirmación con opción de ver el carrito
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.nombre} agregado al carrito'),
                        action: SnackBarAction(
                          label: 'Ver carrito',
                          onPressed: () => Navigator.pushNamed(context, '/cart'),
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(product.stock > 0 ? 'Agregar al carrito' : 'Sin stock'),
          ),
        ),
      ),
    );
  }
}
