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
  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      await _api.post('/products', data, auth: true);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
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
