import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';

/// Pantalla de gestión de inventario / stock para el vendedor.
///
/// Diseño con:
/// - Barra de búsqueda por nombre o SKU
/// - Dos tarjetas métricas (STOCK TOTAL / BAJO STOCK)
/// - Lista "Productos en Existencia" con controles +/- inline
/// - FAB naranja para agregar existencias
class AdminStockScreen extends StatefulWidget {
  const AdminStockScreen({super.key});

  @override
  State<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends State<AdminStockScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _showFilters = false;
  String _activeFilter = 'TODOS'; // TODOS, BAJO, AGOTADO

  /// Umbral para considerar stock bajo.
  static const int _lowStockThreshold = 10;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminProductsProvider>().loadProducts());
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Genera un SKU legible a partir de un producto.
  String _generateSku(ProductModel p) {
    final raw = (p.categoria ?? 'GEN');
    final cat = raw.substring(0, raw.length >= 2 ? 2 : raw.length).toUpperCase();
    return '$cat-${p.id.toString().padLeft(2, '0')}';
  }

  /// Filtra y ordena productos según búsqueda y filtro activo.
  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var filtered = List<ProductModel>.from(products);

    // Búsqueda por nombre o SKU
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final sku = _generateSku(p).toLowerCase();
        return p.nombre.toLowerCase().contains(_searchQuery) || sku.contains(_searchQuery);
      }).toList();
    }

    // Filtro activo
    if (_activeFilter == 'BAJO') {
      filtered = filtered.where((p) => p.stock > 0 && p.stock <= _lowStockThreshold).toList();
    } else if (_activeFilter == 'AGOTADO') {
      filtered = filtered.where((p) => p.stock == 0).toList();
    }

    // Ordenar solo por nombre (orden estable que no cambia al editar stock)
    filtered.sort((a, b) => a.nombre.compareTo(b.nombre));

    return filtered;
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AdminProductsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.products.isEmpty) {
              return const AppLoadingIndicator();
            }
            if (provider.error != null && provider.products.isEmpty) {
              return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadProducts());
            }

            final allProducts = provider.products;
            final filtered = _filterProducts(allProducts);
            final totalStock = allProducts.fold<int>(0, (sum, p) => sum + p.stock);
            final lowStockCount = allProducts.where((p) => p.stock <= _lowStockThreshold).length;

            return RefreshIndicator(
              color: const Color(0xFFE8734A),
              onRefresh: () => provider.loadProducts(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildMetricCards(totalStock, lowStockCount)),
                  SliverToBoxAdapter(child: _buildSectionHeader()),
                  if (_showFilters) SliverToBoxAdapter(child: _buildFilterChips()),
                  if (filtered.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: AppEmptyWidget(message: 'No hay productos')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildProductCard(filtered[index], provider),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          // Botón regresar
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Inventario',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 20),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.35)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o SKU...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchCtrl.clear())
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // METRIC CARDS
  // ─────────────────────────────────────────────────────────────

  Widget _buildMetricCards(int totalStock, int lowStockCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          // STOCK TOTAL
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STOCK TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatNumber(totalStock),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // BAJO STOCK
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8734A).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BAJO STOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE8734A).withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$lowStockCount',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE8734A),
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE8734A), size: 22),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION HEADER + FILTERS
  // ─────────────────────────────────────────────────────────────

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          const Text(
            'Productos en Existencia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Text(
              _showFilters ? 'Ocultar Filtros' : 'Ver Filtros',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE8734A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          _filterChip('TODOS'),
          const SizedBox(width: 8),
          _filterChip('BAJO'),
          const SizedBox(width: 8),
          _filterChip('AGOTADO'),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isActive = _activeFilter == label;
    final displayLabel = label == 'BAJO' ? 'BAJO STOCK' : label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8734A).withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFE8734A) : AppColors.divider.withValues(alpha: 0.4),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? const Color(0xFFE8734A) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUCT CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildProductCard(ProductModel product, AdminProductsProvider provider) {
    final isLow = product.stock > 0 && product.stock <= _lowStockThreshold;
    final isOut = product.stock == 0;
    final sku = _generateSku(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOut
              ? AppColors.error.withValues(alpha: 0.4)
              : isLow
              ? const Color(0xFFE8734A).withValues(alpha: 0.35)
              : AppColors.divider.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // Imagen
          _buildProductImage(product, isLow || isOut),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  'SKU: $sku',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                if (isOut)
                  const Text(
                    'Sin existencias',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                  )
                else if (isLow)
                  Text(
                    'Quedan ${product.stock} unidades',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE8734A)),
                  )
                else
                  Text(
                    'Stock: ${product.stock} unidades',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          // Controles +/-
          _buildStockControls(product, provider),
        ],
      ),
    );
  }

  /// Imagen del producto con badge BAJO / SIN
  Widget _buildProductImage(ProductModel product, bool showBadge) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 68,
              height: 68,
              child: product.imagenUrl != null && product.imagenUrl!.isNotEmpty
                  ? Image.network(
                      product.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
          ),
          if (showBadge)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.stock == 0 ? AppColors.error : const Color(0xFFE8734A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.stock == 0 ? 'SIN' : 'BAJO',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      color: AppColors.inputFill,
      child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 28),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STOCK CONTROLS (+/-)
  // ─────────────────────────────────────────────────────────────

  Widget _buildStockControls(ProductModel product, AdminProductsProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stockControlButton(
          icon: Icons.remove,
          color: AppColors.primary,
          bgColor: AppColors.primary.withValues(alpha: 0.1),
          onTap: product.stock > 0 ? () => _updateStock(product, product.stock - 1, provider) : null,
        ),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            '${product.stock}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        _stockControlButton(
          icon: Icons.add,
          color: Colors.white,
          bgColor: const Color(0xFFE8734A),
          onTap: () => _updateStock(product, product.stock + 1, provider),
        ),
      ],
    );
  }

  Widget _stockControlButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: disabled ? bgColor.withValues(alpha: 0.3) : bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: disabled ? color.withValues(alpha: 0.4) : color),
      ),
    );
  }

  /// Actualiza el stock del producto de forma optimista (sin recargar toda la lista).
  Future<void> _updateStock(ProductModel product, int newStock, AdminProductsProvider provider) async {
    if (newStock < 0) return;
    await provider.updateStockOnly(product.id, newStock);
  }

  // ─────────────────────────────────────────────────────────────
  // FAB + ADD STOCK DIALOG
  // ─────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _showAddStockDialog,
      backgroundColor: const Color(0xFFE8734A),
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  /// Bottom sheet para agregar existencias a un producto.
  void _showAddStockDialog() {
    final provider = context.read<AdminProductsProvider>();
    final products = provider.products;
    ProductModel? selected;
    final qtyCtrl = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Agregar Existencias',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  // Selector de producto
                  DropdownButtonFormField<ProductModel>(
                    value: selected,
                    onChanged: (val) => setModalState(() => selected = val),
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Seleccionar producto',
                      labelStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  // Cantidad
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad a agregar',
                      labelStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Confirmar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selected == null) return;
                        final qty = int.tryParse(qtyCtrl.text) ?? 0;
                        if (qty <= 0) return;
                        Navigator.pop(ctx);
                        await _updateStock(selected!, selected!.stock + qty, provider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8734A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Confirmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Formatea números grandes (ej. 1240 → "1,240").
  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
