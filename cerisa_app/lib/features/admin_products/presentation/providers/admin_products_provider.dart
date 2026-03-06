import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';

/// Provider que gestiona las operaciones CRUD de productos (administración).
///
/// Reutiliza [ProductModel] del catálogo para representar los productos.
/// Proporciona métodos para cargar, crear, actualizar y eliminar productos
/// a través del API REST.
class AdminProductsProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el backend.
  final ApiService _api;

  /// Constructor que recibe el servicio de API.
  AdminProductsProvider(this._api);

  /// Lista interna de productos cargados desde el servidor.
  List<ProductModel> _products = [];

  /// Indica si hay una operación de carga en curso.
  bool _isLoading = false;

  /// Mensaje de error de la última operación fallida.
  String? _error;

  /// Lista de productos (solo lectura).
  List<ProductModel> get products => _products;

  /// Indica si hay una carga en curso.
  bool get isLoading => _isLoading;

  /// Mensaje de error actual.
  String? get error => _error;

  /// Carga todos los productos del catálogo desde el servidor.
  ///
  /// Llama a `GET /products` y parsea la respuesta a [ProductModel].
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/products');
      _products = list.map((j) => ProductModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crea un nuevo producto en el servidor.
  ///
  /// Envía `POST /products` con los datos proporcionados.
  /// Si es exitoso, recarga la lista de productos.
  /// Retorna `true` si la creación fue exitosa.
  /// Retorna el ID del producto creado, o -1 si falla.
  Future<int> createProduct(Map<String, dynamic> data) async {
    try {
      final result = await _api.post('/products', data, auth: true);
      await loadProducts();
      if (result is Map && result['id'] != null) {
        return (result['id'] as num).toInt();
      }
      // Si no viene ID, buscar por nombre en la lista recargada
      final nombre = data['nombre'] as String?;
      if (nombre != null) {
        final found = _products.where((p) => p.nombre == nombre).toList();
        if (found.isNotEmpty) return found.last.id;
      }
      return -1;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return -1;
    }
  }

  /// Actualiza un producto existente en el servidor.
  ///
  /// Envía `PUT /products/{id}` con los datos actualizados.
  /// Si es exitoso, recarga la lista de productos.
  /// Retorna `true` si la actualización fue exitosa.
  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await _api.put('/products/$id', data, auth: true);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Actualización optimista de stock: modifica localmente primero y
  /// luego sincroniza con el servidor sin recargar toda la lista.
  /// Si falla, revierte al valor anterior.
  Future<bool> updateStockOnly(int id, int newStock) async {
    // Encontrar el producto
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx == -1) return false;

    final product = _products[idx];
    final oldStock = product.stock;

    // Optimistic update: cambiar localmente de inmediato
    _products[idx] = ProductModel(
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      stock: newStock,
      categoria: product.categoria,
      imagenUrl: product.imagenUrl,
    );
    notifyListeners();

    // Enviar al servidor sin recargar la lista completa
    try {
      await _api.put('/products/$id', {
        'nombre': product.nombre,
        'descripcion': product.descripcion ?? '',
        'precio': product.precio,
        'stock': newStock,
        'categoria': product.categoria ?? '',
      }, auth: true);
      return true;
    } catch (e) {
      // Revertir en caso de error
      _products[idx] = ProductModel(
        id: product.id,
        nombre: product.nombre,
        descripcion: product.descripcion,
        precio: product.precio,
        stock: oldStock,
        categoria: product.categoria,
        imagenUrl: product.imagenUrl,
      );
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Elimina un producto del servidor.
  ///
  /// Envía `DELETE /products/{id}` con autenticación JWT.
  /// Si es exitoso, recarga la lista de productos.
  /// Retorna `true` si la eliminación fue exitosa.
  Future<bool> deleteProduct(int id) async {
    try {
      await _api.delete('/products/$id', auth: true);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
