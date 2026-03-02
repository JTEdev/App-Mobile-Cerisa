import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';

/// Pantalla de catálogo de productos para el vendedor/admin.
///
/// Muestra los productos con badges de estado (LIVE, DRAFT, LOW STOCK),
/// filtros por pestaña, búsqueda y acciones rápidas por producto.
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Set local de IDs de productos "activos" (toggle on)
  final Set<int> _activeProducts = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    Future.microtask(() => context.read<AdminProductsProvider>().loadProducts());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Inicializa los toggles la primera vez que se cargan los
  /// productos: todos los que tienen stock > 0 quedan activos.
  void _initToggles(List<ProductModel> products) {
    if (_initialized) return;
    _initialized = true;
    for (final p in products) {
      if (p.stock > 0) _activeProducts.add(p.id);
    }
  }

  /// Determina el estado visual de un producto.
  _ProductStatus _statusOf(ProductModel p) {
    if (p.stock == 0) return _ProductStatus.outOfStock;
    if (p.stock <= 5) return _ProductStatus.lowStock;
    if (!_activeProducts.contains(p.id)) return _ProductStatus.draft;
    return _ProductStatus.live;
  }

  /// Filtra productos según la pestaña activa y la búsqueda.
  List<ProductModel> _filtered(List<ProductModel> all) {
    var list = all;
    // Filtro por pestaña
    switch (_tabController.index) {
      case 1: // ACTIVE
        list = list.where((p) => _activeProducts.contains(p.id) && p.stock > 0).toList();
        break;
      case 2: // OUT OF STOCK
        list = list.where((p) => p.stock == 0).toList();
        break;
    }
    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (p.categoria?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Catálogo Productos',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context),
        backgroundColor: const Color(0xFFE8734A),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Consumer<AdminProductsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const AppLoadingIndicator();
          if (provider.error != null) {
            return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadProducts());
          }
          if (provider.products.isEmpty) {
            return const AppEmptyWidget(message: 'No hay productos');
          }

          _initToggles(provider.products);
          final filtered = _filtered(provider.products);

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // ── Buscador ──
                    Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: _buildSearchBar()),
                    // ── Tabs ──
                    _buildTabs(),
                  ],
                ),
              ),
              // ── Lista de productos ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _initialized = false;
                    await provider.loadProducts();
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  'No hay productos en esta categoría',
                                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _buildProductCard(filtered[index], provider),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Barra de búsqueda
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }

  /// Pestañas de filtro
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color(0xFFE8734A),
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: const Color(0xFFE8734A),
      indicatorWeight: 2.5,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: 'TODOS'),
        Tab(text: 'ACTIVOS'),
        Tab(text: 'SIN STOCK'),
      ],
    );
  }

  /// Tarjeta de producto completa con badge, toggle y acciones
  Widget _buildProductCard(ProductModel product, AdminProductsProvider provider) {
    final status = _statusOf(product);
    final isActive = _activeProducts.contains(product.id);
    final isLowStock = status == _ProductStatus.lowStock;
    final isOutOfStock = status == _ProductStatus.outOfStock;

    // Color del borde lateral según estado
    Color borderColor;
    switch (status) {
      case _ProductStatus.lowStock:
        borderColor = const Color(0xFFE8A534);
        break;
      case _ProductStatus.outOfStock:
        borderColor = AppColors.error;
        break;
      default:
        borderColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: borderColor, width: borderColor == Colors.transparent ? 0 : 4),
            ),
          ),
          child: Column(
            children: [
              // ── Fila principal: imagen + info + toggle ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen + badge
                    _buildImageWithBadge(product, status),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre
                          Text(
                            product.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Precio
                          Text(
                            '\$${product.precio.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFE8734A)),
                          ),
                          const SizedBox(height: 4),
                          // Stock info
                          if (isLowStock)
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFE8A534)),
                                const SizedBox(width: 4),
                                Text(
                                  '¡Solo ${product.stock} disponibles!',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE8A534),
                                  ),
                                ),
                              ],
                            )
                          else if (isOutOfStock)
                            const Row(
                              children: [
                                Icon(Icons.error_outline, size: 14, color: AppColors.error),
                                SizedBox(width: 4),
                                Text(
                                  'Sin stock',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stock: ${product.stock} unidades',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Toggle
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isActive,
                        onChanged: (val) {
                          setState(() {
                            if (val) {
                              _activeProducts.add(product.id);
                            } else {
                              _activeProducts.remove(product.id);
                            }
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFFE8734A),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.divider,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Divider ──
              Divider(color: AppColors.divider.withValues(alpha: 0.3), height: 1),
              // ── Acciones ──
              _buildActionRow(product, provider, status),
            ],
          ),
        ),
      ),
    );
  }

  /// Imagen del producto con badge de estado
  Widget _buildImageWithBadge(ProductModel product, _ProductStatus status) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imagenUrl != null && product.imagenUrl!.isNotEmpty
                ? Image.network(
                    product.imagenUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          // Badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _badgeColor(status), borderRadius: BorderRadius.circular(4)),
              child: Text(
                _badgeLabel(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
      child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 30),
    );
  }

  Color _badgeColor(_ProductStatus status) {
    switch (status) {
      case _ProductStatus.live:
        return AppColors.success;
      case _ProductStatus.draft:
        return AppColors.textSecondary;
      case _ProductStatus.lowStock:
        return const Color(0xFFE8A534);
      case _ProductStatus.outOfStock:
        return AppColors.error;
    }
  }

  String _badgeLabel(_ProductStatus status) {
    switch (status) {
      case _ProductStatus.live:
        return 'ACTIVO';
      case _ProductStatus.draft:
        return 'INACTIVO';
      case _ProductStatus.lowStock:
        return 'BAJO STOCK';
      case _ProductStatus.outOfStock:
        return 'SIN STOCK';
    }
  }

  /// Fila de botones de acción por producto
  Widget _buildActionRow(ProductModel product, AdminProductsProvider provider, _ProductStatus status) {
    // Decidir qué acciones mostrar según el estado
    List<_ActionDef> actions;
    if (status == _ProductStatus.draft || status == _ProductStatus.outOfStock) {
      actions = [
        _ActionDef(Icons.edit_outlined, 'Editar', () => _navigateToEdit(product)),
        _ActionDef(Icons.bar_chart_outlined, 'Stats', () {}),
        _ActionDef(Icons.delete_outline, 'Eliminar', () => _confirmDelete(context, product.id, product.nombre)),
      ];
    } else if (status == _ProductStatus.lowStock) {
      actions = [
        _ActionDef(Icons.edit_outlined, 'Editar', () => _navigateToEdit(product)),
        _ActionDef(Icons.add_shopping_cart, 'Reponer', () => _showRestockDialog(context, product, provider)),
        _ActionDef(Icons.archive_outlined, 'Archivar', () {
          setState(() => _activeProducts.remove(product.id));
        }),
      ];
    } else {
      actions = [
        _ActionDef(Icons.edit_outlined, 'Editar', () => _navigateToEdit(product)),
        _ActionDef(Icons.bar_chart_outlined, 'Stats', () {}),
        _ActionDef(Icons.archive_outlined, 'Archivar', () {
          setState(() => _activeProducts.remove(product.id));
        }),
      ];
    }

    return SizedBox(
      height: 44,
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: InkWell(
              onTap: a.onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    a.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Diálogo para reponer stock
  void _showRestockDialog(BuildContext context, ProductModel product, AdminProductsProvider provider) {
    final stockCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reponer Stock', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.nombre} — Stock actual: ${product.stock}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nuevo stock total',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockCtrl.text);
              if (newStock == null || newStock < 0) return;
              Navigator.pop(ctx);
              await provider.updateProduct(product.id, {
                'nombre': product.nombre,
                'precio': product.precio,
                'stock': newStock,
                if (product.descripcion != null) 'descripcion': product.descripcion,
                if (product.categoria != null) 'categoria': product.categoria,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8734A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Actualizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Navegar a la pantalla completa de editar producto
  void _navigateToEdit(ProductModel product) async {
    final result = await Navigator.pushNamed(context, AppRoutes.editProduct, arguments: product);
    // Si se guardó o eliminó, recargar la lista
    if (result == true && mounted) {
      context.read<AdminProductsProvider>().loadProducts();
    }
  }

  /// Formulario para crear o editar un producto (modal)
  void _showProductForm(BuildContext context, {ProductModel? product}) {
    final nombreCtrl = TextEditingController(text: product?.nombre ?? '');
    final descripcionCtrl = TextEditingController(text: product?.descripcion ?? '');
    final precioCtrl = TextEditingController(text: product != null ? product.precio.toString() : '');
    final stockCtrl = TextEditingController(text: product != null ? product.stock.toString() : '');
    final categoriaCtrl = TextEditingController(text: product?.categoria ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product != null ? 'Editar Producto' : 'Nuevo Producto',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                _formField(nombreCtrl, 'Nombre *', validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null),
                const SizedBox(height: 12),
                _formField(descripcionCtrl, 'Descripción', maxLines: 2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _formField(
                        precioCtrl,
                        'Precio *',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (double.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _formField(
                        stockCtrl,
                        'Stock *',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (int.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _formField(categoriaCtrl, 'Categoría'),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final data = {
                        'nombre': nombreCtrl.text,
                        'descripcion': descripcionCtrl.text,
                        'precio': double.parse(precioCtrl.text),
                        'stock': int.parse(stockCtrl.text),
                        'categoria': categoriaCtrl.text,
                      };
                      final provider = context.read<AdminProductsProvider>();
                      bool ok;
                      if (product != null) {
                        ok = await provider.updateProduct(product.id, data);
                      } else {
                        ok = await provider.createProduct(data);
                      }
                      if (ok) {
                        _initialized = false;
                      }
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8734A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      product != null ? 'Actualizar Producto' : 'Crear Producto',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 14),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Confirmación de eliminación
  void _confirmDelete(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "$nombre"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProductsProvider>().deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Estados visuales de un producto.
enum _ProductStatus { live, draft, lowStock, outOfStock }

/// Definición de una acción del producto.
class _ActionDef {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionDef(this.icon, this.label, this.onTap);
}
