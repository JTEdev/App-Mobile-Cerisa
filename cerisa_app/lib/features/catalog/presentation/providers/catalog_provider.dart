import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';

/// Modelo de datos que representa un producto del catálogo.
///
/// Mapea la estructura JSON devuelta por el endpoint `/products`
/// del API backend. Incluye información básica como nombre,
/// precio, stock, categoría e imagen.
class ProductModel {
  /// Identificador único del producto.
  final int id;

  /// Nombre del producto.
  final String nombre;

  /// Descripción detallada del producto (puede ser nula).
  final String? descripcion;

  /// Precio unitario del producto en soles (S/).
  final double precio;

  /// Cantidad disponible en inventario.
  final int stock;

  /// Categoría del producto (puede ser nula).
  final String? categoria;

  /// URL de la imagen del producto (puede ser nula).
  final String? imagenUrl;

  /// Constructor del modelo de producto.
  ProductModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.categoria,
    this.imagenUrl,
  });

  /// Crea una instancia de [ProductModel] a partir de un mapa JSON.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] as int,
      categoria: json['categoria'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
    );
  }
}

/// Provider que gestiona el estado del catálogo de productos.
///
/// Carga la lista de productos desde el API y la expone a los
/// widgets consumidores. Proporciona métodos para cargar productos
/// y buscar por ID.
class CatalogProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el API.
  final ApiService _api;

  /// Constructor que recibe el servicio de API inyectado.
  CatalogProvider(this._api);

  /// Lista interna de productos cargados.
  List<ProductModel> _products = [];

  /// Indica si se están cargando los productos.
  bool _isLoading = false;

  /// Mensaje de error de la última carga, o `null` si no hay error.
  String? _error;

  /// Indica si ya se cargaron los productos al menos una vez.
  bool _isLoaded = false;

  /// Lista de productos disponibles (solo lectura).
  List<ProductModel> get products => _products;

  /// Indica si hay una carga en curso.
  bool get isLoading => _isLoading;

  /// Mensaje de error actual.
  String? get error => _error;

  /// Carga la lista de productos desde el API (`GET /products`).
  ///
  /// Actualiza [_products] con los resultados y notifica a los listeners.
  /// En caso de error, almacena el mensaje en [_error].
  /// Si [force] es false y ya se cargaron antes, no hace nada.
  Future<void> loadProducts({bool force = false}) async {
    if (_isLoading) return;
    if (_isLoaded && !force && _error == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/products');
      // Transformar cada JSON en un ProductModel
      _products = list.map((j) => ProductModel.fromJson(j)).toList();
      _isLoaded = true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Busca un producto por su [id] en la lista cargada en memoria.
  ///
  /// Retorna el [ProductModel] encontrado, o `null` si no existe.
  ProductModel? getById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
