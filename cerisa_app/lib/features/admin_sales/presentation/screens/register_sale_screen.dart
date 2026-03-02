import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/admin_users/presentation/providers/admin_users_provider.dart';

/// Item de la venta temporal (producto + cantidad).
class _SaleItem {
  final ProductModel product;
  int cantidad;
  _SaleItem({required this.product, this.cantidad = 1});
  double get subtotal => product.precio * cantidad;
}

/// Pantalla para registrar ventas directas desde el panel del vendedor.
///
/// Permite buscar productos, agregarlos a la venta, ajustar cantidades,
/// asociar un cliente (opcional) y confirmar la transacción.
class RegisterSaleScreen extends StatefulWidget {
  const RegisterSaleScreen({super.key});

  @override
  State<RegisterSaleScreen> createState() => _RegisterSaleScreenState();
}

class _RegisterSaleScreenState extends State<RegisterSaleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<_SaleItem> _saleItems = [];
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  bool _isConfirming = false;
  UserModel? _selectedClient;

  double get _subtotal => _saleItems.fold(0, (sum, item) => sum + item.subtotal);
  double get _impuestos => 0.0;
  double get _total => _subtotal + _impuestos;
  int get _totalItems => _saleItems.fold(0, (sum, item) => sum + item.cantidad);

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts(String query) {
    final catalog = context.read<CatalogProvider>();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = catalog.products
            .where(
              (p) =>
                  p.nombre.toLowerCase().contains(query.toLowerCase()) ||
                  (p.categoria?.toLowerCase().contains(query.toLowerCase()) ?? false),
            )
            .toList();
      }
    });
  }

  void _addProduct(ProductModel product) {
    setState(() {
      final existing = _saleItems.where((item) => item.product.id == product.id);
      if (existing.isNotEmpty) {
        existing.first.cantidad++;
      } else {
        _saleItems.add(_SaleItem(product: product));
      }
      _searchController.clear();
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _saleItems[index].cantidad += delta;
      if (_saleItems[index].cantidad <= 0) {
        _saleItems.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _saleItems.removeAt(index);
    });
  }

  Future<void> _confirmSale() async {
    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Agrega al menos un producto a la venta')));
      return;
    }

    setState(() => _isConfirming = true);

    try {
      final api = context.read<ApiService>();
      final items = _saleItems.map((item) => {'productoId': item.product.id, 'cantidad': item.cantidad}).toList();

      final body = <String, dynamic>{
        'items': items,
        if (_selectedClient != null) 'notas': 'Venta directa - Cliente: ${_selectedClient!.nombre}',
      };

      await api.post('/orders', body, auth: true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Venta registrada exitosamente!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar venta: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  void _showClientPicker() async {
    final usersProvider = context.read<AdminUsersProvider>();
    await usersProvider.loadUsers();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ClientPickerSheet(
        users: usersProvider.users.where((u) => u.rol == 'CLIENTE').toList(),
        onSelected: (user) {
          setState(() => _selectedClient = user);
          Navigator.pop(ctx);
        },
      ),
    );
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
          'Registrar Venta',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Buscador ──
                  _buildSearchBar(),
                  // ── Resultados de búsqueda ──
                  if (_isSearching) _buildSearchResults(),
                  const SizedBox(height: 20),
                  // ── Productos en la venta ──
                  _buildSaleItemsSection(),
                  const SizedBox(height: 24),
                  // ── Asociar cliente ──
                  _buildClientSection(),
                  const SizedBox(height: 24),
                  // ── Resumen de la venta ──
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ── Botones fijos ──
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Barra de búsqueda de productos
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchProducts,
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 15),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// Resultados del buscador
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'No se encontraron productos',
            style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 13),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) => Divider(color: AppColors.divider.withValues(alpha: 0.3), height: 1),
        itemBuilder: (context, index) {
          final product = _searchResults[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: _buildProductThumbnail(product, size: 40),
            title: Text(
              product.nombre,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '\$${product.precio.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE8734A)),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8734A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Color(0xFFE8734A), size: 18),
            ),
            onTap: () => _addProduct(product),
          );
        },
      ),
    );
  }

  /// Thumbnail del producto
  Widget _buildProductThumbnail(ProductModel product, {double size = 60}) {
    if (product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          product.imagenUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(size),
        ),
      );
    }
    return _buildPlaceholderImage(size);
  }

  Widget _buildPlaceholderImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4), size: size * 0.5),
    );
  }

  /// Sección "Productos en la venta"
  Widget _buildSaleItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text(
              'Productos en la venta',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const Spacer(),
            if (_saleItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8734A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_totalItems ítems',
                  style: const TextStyle(color: Color(0xFFE8734A), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Lista de items
        if (_saleItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Text(
                    'Busca y agrega productos',
                    style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_saleItems.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index < _saleItems.length - 1 ? 10 : 0),
              child: _buildSaleItemCard(_saleItems[index], index),
            );
          }),
      ],
    );
  }

  /// Tarjeta de item de venta con imagen, nombre, precio y controles de cantidad
  Widget _buildSaleItemCard(_SaleItem item, int index) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
      ),
      onDismissed: (_) => _removeItem(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Imagen del producto
            _buildProductThumbnail(item.product),
            const SizedBox(width: 12),
            // Nombre y precio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.nombre,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFE8734A)),
                  ),
                ],
              ),
            ),
            // Controles de cantidad
            _buildQuantityControls(item.cantidad, index),
          ],
        ),
      ),
    );
  }

  /// Controles +/- para la cantidad
  Widget _buildQuantityControls(int cantidad, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón menos
        _buildQuantityButton(icon: Icons.remove, onTap: () => _updateQuantity(index, -1), filled: false),
        // Cantidad
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text(
            '$cantidad',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        // Botón más
        _buildQuantityButton(icon: Icons.add, onTap: () => _updateQuantity(index, 1), filled: true),
      ],
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap, required bool filled}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFE8734A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Icon(icon, size: 18, color: filled ? Colors.white : AppColors.textSecondary),
      ),
    );
  }

  /// Sección "Asociar Cliente (Opcional)"
  Widget _buildClientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asociar Cliente (Opcional)',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showClientPicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE8734A).withValues(alpha: 0.3),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8734A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_add_outlined, color: Color(0xFFE8734A), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _selectedClient != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedClient!.nombre,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedClient!.email,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : Text(
                          'Seleccionar o crear cliente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                ),
                if (_selectedClient != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedClient = null),
                    child: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                  )
                else
                  Icon(Icons.chevron_right, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tarjeta resumen de la venta
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Subtotal
          _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          // Impuestos
          _buildSummaryRow('Impuestos (Incl.)', '\$${_impuestos.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          // Divider
          Divider(color: AppColors.divider.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: 14),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFFE8734A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  /// Botones "Confirmar Venta" y "Cancelar" fijos al fondo
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confirmar Venta
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isConfirming ? null : _confirmSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8734A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isConfirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text('Confirmar Venta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Cancelar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E8F0).withValues(alpha: 0.5),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// BottomSheet para seleccionar un cliente
class _ClientPickerSheet extends StatefulWidget {
  final List<UserModel> users;
  final ValueChanged<UserModel> onSelected;

  const _ClientPickerSheet({required this.users, required this.onSelected});

  @override
  State<_ClientPickerSheet> createState() => _ClientPickerSheetState();
}

class _ClientPickerSheetState extends State<_ClientPickerSheet> {
  String _filter = '';

  List<UserModel> get _filtered {
    if (_filter.isEmpty) return widget.users;
    return widget.users
        .where(
          (u) =>
              u.nombre.toLowerCase().contains(_filter.toLowerCase()) ||
              u.email.toLowerCase().contains(_filter.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Seleccionar Cliente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _filter = v),
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron clientes',
                      style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(color: AppColors.divider.withValues(alpha: 0.3), height: 1),
                    itemBuilder: (context, index) {
                      final user = _filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE8734A).withValues(alpha: 0.12),
                          child: Text(
                            user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                            style: const TextStyle(color: Color(0xFFE8734A), fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(
                          user.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          user.email,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        onTap: () => widget.onSelected(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
