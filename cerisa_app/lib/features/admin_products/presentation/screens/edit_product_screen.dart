import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';

/// Pantalla completa para editar o crear un producto.
///
/// Replica el diseño con imagen grande, galería de miniaturas,
/// campos de información general, inventario (SKU + stock),
/// toggle de publicación y botones de guardar/eliminar.
class EditProductScreen extends StatefulWidget {
  /// Producto a editar (null = crear nuevo).
  final ProductModel? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _categoriaCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _skuCtrl;
  late int _stock;
  bool _publicado = true;
  bool _isSaving = false;
  bool _isUploading = false;

  /// Imagen seleccionada localmente (antes de subir).
  File? _pickedImage;

  /// URL de imagen actual del producto (del servidor).
  String? _currentImageUrl;

  final _picker = ImagePicker();

  bool get _isEditing => widget.product != null;

  /// Categorías disponibles para el dropdown.
  static const _categorias = ['Artesanías', 'Decoración', 'Textiles', 'Cerámica', 'Joyería', 'Otro'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _categoriaCtrl = TextEditingController(text: p?.categoria ?? '');
    _precioCtrl = TextEditingController(text: p != null ? p.precio.toStringAsFixed(2) : '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _skuCtrl = TextEditingController(text: p != null ? _generateSku(p) : '');
    _stock = p?.stock ?? 0;
    _publicado = p != null ? p.stock > 0 : true;
    _currentImageUrl = p?.imagenUrl;
  }

  String _generateSku(ProductModel p) {
    // Genera un SKU simple basado en la categoría y el ID
    final cat = (p.categoria ?? 'GEN').substring(0, 3).toUpperCase();
    return 'CER-$cat-${p.id.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _categoriaCtrl.dispose();
    _precioCtrl.dispose();
    _descripcionCtrl.dispose();
    _skuCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
      'precio': double.parse(_precioCtrl.text),
      'stock': _stock,
      'categoria': _categoriaCtrl.text.trim(),
      if (_currentImageUrl != null) 'imagenUrl': _currentImageUrl,
    };

    final provider = context.read<AdminProductsProvider>();
    bool ok;

    if (_isEditing) {
      ok = await provider.updateProduct(widget.product!.id, data);
      // Si hay imagen local pendiente, subirla
      if (ok && _pickedImage != null) {
        await _uploadImage(_pickedImage!);
      }
    } else {
      final newId = await provider.createProduct(data);
      ok = newId > 0;
      // Si se creó el producto y hay imagen local, subirla
      if (ok && _pickedImage != null) {
        final api = context.read<ApiService>();
        try {
          await api.uploadFile('/products/$newId/image', filePath: _pickedImage!.path);
        } catch (_) {
          // Producto creado pero imagen falló — no bloquear
        }
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Producto actualizado' : 'Producto creado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error ?? 'Error desconocido'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar "${widget.product!.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await context.read<AdminProductsProvider>().deleteProduct(widget.product!.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Producto eliminado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop(true);
    }
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
        title: Text(
          _isEditing ? 'Editar Producto' : 'Nuevo Producto',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Imagen principal ──
                    _buildMainImage(),
                    const SizedBox(height: 12),
                    // ── Galería miniaturas ──
                    _buildThumbnailGallery(),
                    const SizedBox(height: 28),
                    // ── Información General ──
                    _buildSectionTitle('Información General'),
                    const SizedBox(height: 16),
                    _buildLabel('Nombre del Producto'),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _nombreCtrl,
                      hint: 'Nombre del producto',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 18),
                    _buildLabel('Categoría'),
                    const SizedBox(height: 6),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 18),
                    _buildLabel('Precio'),
                    const SizedBox(height: 6),
                    _buildPriceInput(),
                    const SizedBox(height: 18),
                    _buildLabel('Descripción'),
                    const SizedBox(height: 6),
                    _buildTextInput(controller: _descripcionCtrl, hint: 'Descripción del producto...', maxLines: 5),
                    const SizedBox(height: 28),
                    // ── Inventario ──
                    _buildSectionTitle('Inventario'),
                    const SizedBox(height: 16),
                    _buildInventoryRow(),
                    const SizedBox(height: 20),
                    // ── Toggle publicar ──
                    _buildPublishToggle(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // ── Botones ──
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  /// Selecciona una imagen de la galería y la sube al servidor.
  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _pickedImage = file;
    });

    // Si estamos editando, subir inmediatamente
    if (_isEditing) {
      await _uploadImage(file);
    }
  }

  /// Sube la imagen al servidor.
  Future<void> _uploadImage(File file) async {
    if (!_isEditing) return; // Solo para productos existentes
    setState(() => _isUploading = true);
    try {
      final api = context.read<ApiService>();
      final result = await api.uploadFile('/products/${widget.product!.id}/image', filePath: file.path);
      final newUrl = result['imagenUrl'] as String?;
      if (newUrl != null && mounted) {
        setState(() {
          _currentImageUrl = newUrl;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Imagen actualizada'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isUploading = false);
  }

  /// Construye la URL completa de la imagen para mostrar.
  String? _fullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    if (relativeUrl.startsWith('http')) return relativeUrl;
    // Construir URL completa: base host + relative path
    return 'http://10.0.2.2:8081$relativeUrl';
  }

  /// Imagen principal con overlay "Actualizar Foto"
  Widget _buildMainImage() {
    final fullUrl = _fullImageUrl(_currentImageUrl);
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen: local > network > placeholder
              if (_pickedImage != null)
                Image.file(_pickedImage!, fit: BoxFit.cover)
              else if (fullUrl != null)
                Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagePlaceholder())
              else
                _imagePlaceholder(),
              // Gradiente inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                    ),
                  ),
                ),
              ),
              // Botón "Actualizar Foto" / indicador de carga
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Actualizar Foto',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF3E2C1C),
      child: Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.white.withValues(alpha: 0.3))),
    );
  }

  /// Fila de miniaturas + botón de agregar
  Widget _buildThumbnailGallery() {
    final fullUrl = _fullImageUrl(_currentImageUrl);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          // Miniatura principal (con borde naranja = seleccionada)
          _thumbnailBox(
            isSelected: true,
            child: _pickedImage != null
                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                : fullUrl != null
                ? Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _thumbPlaceholder())
                : _thumbPlaceholder(),
          ),
          const SizedBox(width: 10),
          // Miniaturas placeholder
          _thumbnailBox(child: _thumbPlaceholder()),
          const SizedBox(width: 10),
          _thumbnailBox(child: _thumbPlaceholder()),
          const SizedBox(width: 10),
          // Botón agregar foto
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadImage,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8734A).withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Center(child: Icon(Icons.add, color: Color(0xFFE8734A), size: 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnailBox({Widget? child, bool isSelected = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFE8734A) : AppColors.divider.withValues(alpha: 0.4),
          width: isSelected ? 2.5 : 1,
        ),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );
  }

  Widget _thumbPlaceholder() {
    return Container(
      color: AppColors.inputFill,
      child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 22),
    );
  }

  /// Título de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    );
  }

  /// Label de campo
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    );
  }

  /// Input de texto general
  Widget _buildTextInput({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8734A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Dropdown de categoría
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _categorias.contains(_categoriaCtrl.text) ? _categoriaCtrl.text : null,
      onChanged: (val) {
        if (val != null) {
          setState(() => _categoriaCtrl.text = val);
        }
      },
      items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8734A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary.withValues(alpha: 0.6)),
      hint: Text(
        'Selecciona categoría',
        style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
      ),
    );
  }

  /// Input de precio con símbolo $
  Widget _buildPriceInput() {
    return TextFormField(
      controller: _precioCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Obligatorio';
        if (double.tryParse(v) == null) return 'Número inválido';
        return null;
      },
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixText: '\$ ',
        prefixStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8734A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Fila SKU + Stock con controles +/-
  Widget _buildInventoryRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SKU
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('SKU'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8734A).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8734A).withValues(alpha: 0.15)),
                ),
                child: Text(
                  _skuCtrl.text.isNotEmpty ? _skuCtrl.text : 'AUTO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Stock
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Stock'),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Botón menos
                  _stockButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_stock > 0) setState(() => _stock--);
                    },
                  ),
                  // Valor
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_stock',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  // Botón más
                  _stockButton(icon: Icons.add, onTap: () => setState(() => _stock++), filled: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stockButton({required IconData icon, required VoidCallback onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFE8734A).withValues(alpha: 0.12) : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Icon(icon, size: 18, color: filled ? const Color(0xFFE8734A) : AppColors.textSecondary),
      ),
    );
  }

  /// Toggle "Publicar en catálogo"
  Widget _buildPublishToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Publicar en catálogo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'El producto será visible para los clientes',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _publicado,
              onChanged: (val) => setState(() => _publicado = val),
              activeColor: Colors.white,
              activeTrackColor: AppColors.success,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.divider,
            ),
          ),
        ],
      ),
    );
  }

  /// Botones fijos: Guardar Cambios + Eliminar Producto
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Guardar Cambios
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8734A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? 'Guardar Cambios' : 'Crear Producto',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
            // Eliminar (solo en edición)
            if (_isEditing) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _delete,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE8734A).withValues(alpha: 0.08),
                    foregroundColor: const Color(0xFFE8734A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Eliminar Producto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
