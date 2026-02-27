import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';

/// Pantalla de gestión de inventario / stock de productos.
///
/// Muestra todos los productos ordenados de menor a mayor stock,
/// con indicadores visuales codificados por color:
/// - Rojo: sin stock (agotado).
/// - Naranja: stock bajo (5 o menos).
/// - Verde: stock suficiente.
///
/// Permite editar rápidamente el stock de cualquier producto
/// mediante un diálogo emergente.
class AdminStockScreen extends StatefulWidget {
  /// Constructor constante.
  const AdminStockScreen({super.key});

  @override
  State<AdminStockScreen> createState() => _AdminStockScreenState();
}

/// Estado de [AdminStockScreen].
class _AdminStockScreenState extends State<AdminStockScreen> {
  @override
  void initState() {
    super.initState();
    // Carga la lista de productos al iniciar
    Future.microtask(() => context.read<AdminProductsProvider>().loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión Stock')),
      body: Consumer<AdminProductsProvider>(
        builder: (context, provider, _) {
          // Estados de carga, error y lista vacía
          if (provider.isLoading) return const AppLoadingIndicator();
          if (provider.error != null) {
            return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadProducts());
          }
          if (provider.products.isEmpty) {
            return const AppEmptyWidget(message: 'No hay productos');
          }

          // Ordenar productos de menor a mayor stock para priorizar los bajos
          final sorted = List.of(provider.products)..sort((a, b) => a.stock.compareTo(b.stock));

          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final p = sorted[index];
                // Determinar color según nivel de stock
                final color = p.stock == 0
                    ? Colors
                          .red // Sin stock
                    : p.stock <= 5
                    ? Colors
                          .orange // Stock bajo
                    : Colors.green; // Stock suficiente

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    // Avatar con la cantidad de stock coloreada
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        '${p.stock}',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Nombre del producto
                    title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    // Categoría del producto
                    subtitle: Text(p.categoria ?? 'Sin categoría'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge "AGOTADO" para productos sin stock
                        if (p.stock == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'AGOTADO',
                              style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Botón para editar el stock
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editStock(context, p.id, p.nombre, p.stock, provider),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Muestra un diálogo para editar el stock de un producto.
  ///
  /// [id] es el identificador del producto, [nombre] su nombre,
  /// [currentStock] el stock actual y [provider] el provider para
  /// ejecutar la actualización.
  void _editStock(BuildContext context, int id, String nombre, int currentStock, AdminProductsProvider provider) {
    final ctrl = TextEditingController(text: currentStock.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stock: $nombre'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nuevo stock', prefixIcon: Icon(Icons.inventory)),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(ctrl.text);
              // Validar que sea un número entero válido y no negativo
              if (newStock == null || newStock < 0) return;
              Navigator.pop(ctx);
              // Solo actualizar el campo stock (se envían datos mínimos requeridos)
              await provider.updateProduct(id, {'nombre': nombre, 'precio': 0, 'stock': newStock});
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
