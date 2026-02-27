import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';

/// Modelo que representa un ítem individual dentro del carrito de compras.
///
/// Contiene el producto y la cantidad seleccionada. Calcula el
/// subtotal automáticamente multiplicando precio por cantidad.
class CartItem {
  /// Producto asociado a este ítem del carrito.
  final ProductModel product;

  /// Cantidad de unidades del producto en el carrito.
  int cantidad;

  /// Constructor del ítem de carrito. La cantidad por defecto es 1.
  CartItem({required this.product, this.cantidad = 1});

  /// Calcula el subtotal de este ítem (precio unitario × cantidad).
  double get subtotal => product.precio * cantidad;
}

/// Provider que gestiona el estado del carrito de compras.
///
/// Maneja la lógica de agregar, eliminar y actualizar productos
/// en el carrito, así como el proceso de checkout (crear pedido)
/// llamándo al endpoint `POST /orders` del API.
class CartProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el API.
  final ApiService _api;

  /// Lista interna de ítems en el carrito.
  final List<CartItem> _items = [];

  /// Constructor que recibe el servicio de API.
  CartProvider(this._api);

  /// Lista de ítems del carrito (solo lectura para prevenir modificación externa).
  List<CartItem> get items => List.unmodifiable(_items);

  /// Cantidad total de productos en el carrito (sumando todas las cantidades).
  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  /// Monto total del carrito en soles (suma de todos los subtotales).
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Indica si el carrito está vacío.
  bool get isEmpty => _items.isEmpty;

  /// Indica si hay una operación de checkout en curso.
  bool _isLoading = false;

  /// Mensaje de error del último checkout fallido.
  String? _error;

  /// Getter: indica si hay una operación en curso.
  bool get isLoading => _isLoading;

  /// Getter: mensaje de error actual.
  String? get error => _error;

  /// Agrega un producto al carrito.
  ///
  /// Si el producto ya existe en el carrito, incrementa su cantidad.
  /// Si es nuevo, lo agrega con cantidad 1.
  void addToCart(ProductModel product) {
    final existing = _items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      // El producto ya está en el carrito: incrementar cantidad
      _items[existing].cantidad++;
    } else {
      // Producto nuevo: agregarlo al carrito
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  /// Elimina un producto del carrito por su [productId].
  void removeFromCart(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  /// Actualiza la cantidad de un producto en el carrito.
  ///
  /// Si la nueva [cantidad] es menor o igual a 0, elimina el producto.
  void updateQuantity(int productId, int cantidad) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (cantidad <= 0) {
        // Cantidad 0 o negativa: eliminar el producto del carrito
        _items.removeAt(index);
      } else {
        _items[index].cantidad = cantidad;
      }
      notifyListeners();
    }
  }

  /// Vacía completamente el carrito.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Realiza el proceso de checkout (crear pedido).
  ///
  /// Envía los ítems del carrito al endpoint `POST /orders` con
  /// la [direccion] de entrega y [notas] opcionales.
  /// Si es exitoso, vacía el carrito y retorna `true`.
  /// Si falla, almacena el error y retorna `false`.
  Future<bool> checkout({String? direccion, String? notas}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Construir el cuerpo de la solicitud con los ítems del carrito
      final body = {
        'items': _items.map((item) => {'productoId': item.product.id, 'cantidad': item.cantidad}).toList(),
        // Incluir dirección y notas solo si no están vacías
        if (direccion != null && direccion.isNotEmpty) 'direccionEntrega': direccion,
        if (notas != null && notas.isNotEmpty) 'notas': notas,
      };

      // Enviar el pedido al API (requiere autenticación)
      await _api.post('/orders', body, auth: true);

      // Checkout exitoso: vaciar el carrito
      _items.clear();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
