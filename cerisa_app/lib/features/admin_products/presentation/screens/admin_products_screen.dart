import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';

/// Pantalla de administración de productos.
///
/// Permite al administrador ver la lista completa de productos,
/// crear nuevos productos, editar existentes y eliminarlos.
/// Usa [AdminProductsProvider] para todas las operaciones CRUD.
class AdminProductsScreen extends StatefulWidget {
  /// Constructor constante.
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

/// Estado de [AdminProductsScreen].
class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar productos al inicializar la pantalla
    Future.microtask(() => context.read<AdminProductsProvider>().loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión Productos')),
      // Botón flotante para agregar un nuevo producto
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context),
        child: const Icon(Icons.add),
      ),
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

          // Lista de productos con pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => provider.loadProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final p = provider.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    // Avatar genérico del producto
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.inventory_2, color: Colors.grey),
                    ),
                    // Nombre del producto
                    title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    // Precio y stock del producto
                    subtitle: Text('S/ ${p.precio.toStringAsFixed(2)} • Stock: ${p.stock}'),
                    // Menú con opciones de editar y eliminar
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') _showProductForm(context, product: p);
                        if (value == 'delete') _confirmDelete(context, p.id, p.nombre);
                      },
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

  /// Muestra el formulario modal para crear o editar un producto.
  ///
  /// Si [product] es nulo, se crea un producto nuevo.
  /// Si [product] tiene valor, se pre-llenan los campos para edición.
  void _showProductForm(BuildContext context, {dynamic product}) {
    // Controladores de texto pre-llenados según modo crear/editar
    final nombreCtrl = TextEditingController(text: product?.nombre ?? '');
    final descripcionCtrl = TextEditingController(text: product?.descripcion ?? '');
    final precioCtrl = TextEditingController(text: product != null ? product.precio.toString() : '');
    final stockCtrl = TextEditingController(text: product != null ? product.stock.toString() : '');
    final categoriaCtrl = TextEditingController(text: product?.categoria ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        // Padding inferior dinámico para evitar que el teclado tape el formulario
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título dinámico según modo crear/editar
                Text(
                  product != null ? 'Editar Producto' : 'Nuevo Producto',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Campo: Nombre del producto (obligatorio)
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 12),
                // Campo: Descripción del producto (opcional)
                TextFormField(
                  controller: descripcionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      // Campo: Precio del producto (obligatorio, numérico)
                      child: TextFormField(
                        controller: precioCtrl,
                        decoration: const InputDecoration(labelText: 'Precio *'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (double.tryParse(v) == null) return 'Número inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      // Campo: Stock del producto (obligatorio, entero)
                      child: TextFormField(
                        controller: stockCtrl,
                        decoration: const InputDecoration(labelText: 'Stock *'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (int.tryParse(v) == null) return 'Número entero';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Campo: Categoría del producto (opcional)
                TextFormField(
                  controller: categoriaCtrl,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
                const SizedBox(height: 20),
                // Botón de envío: Crear o Actualizar según contexto
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    // Construir el mapa de datos desde los campos del formulario
                    final data = {
                      'nombre': nombreCtrl.text,
                      'descripcion': descripcionCtrl.text,
                      'precio': double.parse(precioCtrl.text),
                      'stock': int.parse(stockCtrl.text),
                      'categoria': categoriaCtrl.text,
                    };
                    final provider = context.read<AdminProductsProvider>();
                    bool ok;
                    // Decidir si crear o actualizar según si product ya existe
                    if (product != null) {
                      ok = await provider.updateProduct(product.id, data);
                    } else {
                      ok = await provider.createProduct(data);
                    }
                    // Cerrar modal si la operación fue exitosa
                    if (ok && ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(product != null ? 'Actualizar' : 'Crear'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar un producto.
  ///
  /// [id] es el identificador del producto y [nombre] su nombre para mostrar.
  void _confirmDelete(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "$nombre"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Ejecutar eliminación a través del provider
              await context.read<AdminProductsProvider>().deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
