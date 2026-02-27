import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';

/// Modelo de datos que representa un pedido completo.
///
/// Incluye información del estado, total, dirección de entrega,
/// notas, lista de ítems y datos del cliente. Mapea la respuesta
/// JSON del endpoint `/orders`.
class OrderModel {
  /// Identificador único del pedido.
  final int id;

  /// Estado actual del pedido (ej: PENDIENTE, CONFIRMADO, ENVIADO, etc.).
  final String estado;

  /// Monto total del pedido en soles.
  final double total;

  /// Dirección de entrega proporcionada por el cliente (puede ser nula).
  final String? direccionEntrega;

  /// Notas o instrucciones especiales del cliente (puede ser nula).
  final String? notas;

  /// Lista de ítems (productos) incluidos en el pedido.
  final List<OrderItemModel> items;

  /// Nombre del cliente que realizó el pedido.
  final String clienteNombre;

  /// Email del cliente que realizó el pedido.
  final String clienteEmail;

  /// Fecha y hora de creación del pedido (formato ISO 8601, puede ser nula).
  final String? creadoEn;

  /// Constructor del modelo de pedido.
  OrderModel({
    required this.id,
    required this.estado,
    required this.total,
    this.direccionEntrega,
    this.notas,
    required this.items,
    required this.clienteNombre,
    required this.clienteEmail,
    this.creadoEn,
  });

  /// Crea una instancia de [OrderModel] a partir de un mapa JSON.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      estado: json['estado'] as String,
      total: (json['total'] as num).toDouble(),
      direccionEntrega: json['direccionEntrega'] as String?,
      notas: json['notas'] as String?,
      items: (json['items'] as List<dynamic>?)?.map((j) => OrderItemModel.fromJson(j)).toList() ?? [],
      clienteNombre: json['clienteNombre'] as String? ?? '',
      clienteEmail: json['clienteEmail'] as String? ?? '',
      creadoEn: json['creadoEn'] as String?,
    );
  }
}

/// Modelo de datos que representa un ítem individual dentro de un pedido.
///
/// Contiene la referencia al producto, cantidad solicitada,
/// precio unitario al momento de la compra y subtotal.
class OrderItemModel {
  /// ID del producto asociado.
  final int productoId;

  /// Nombre del producto al momento de la compra.
  final String productoNombre;

  /// Cantidad de unidades solicitadas.
  final int cantidad;

  /// Precio unitario del producto al momento de la compra.
  final double precioUnitario;

  /// Subtotal de este ítem (precio unitario × cantidad).
  final double subtotal;

  /// Constructor del modelo de ítem de pedido.
  OrderItemModel({
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  /// Crea una instancia de [OrderItemModel] a partir de un mapa JSON.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      cantidad: json['cantidad'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

/// Provider que gestiona el estado de los pedidos.
///
/// Soporta dos modos de carga:
/// - [loadMyOrders]: carga los pedidos del usuario actual (`GET /orders/my`).
/// - [loadAllOrders]: carga todos los pedidos del sistema para admin (`GET /orders`).
/// También permite actualizar el estado de un pedido con [updateStatus].
class OrdersProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el API.
  final ApiService _api;

  /// Constructor que recibe el servicio de API.
  OrdersProvider(this._api);

  /// Lista interna de pedidos cargados.
  List<OrderModel> _orders = [];

  /// Indica si hay una operación de carga en curso.
  bool _isLoading = false;

  /// Mensaje de error de la última operación fallida.
  String? _error;

  /// Lista de pedidos cargados (solo lectura).
  List<OrderModel> get orders => _orders;

  /// Indica si hay una carga en curso.
  bool get isLoading => _isLoading;

  /// Mensaje de error actual.
  String? get error => _error;

  /// Carga los pedidos del usuario autenticado actualmente.
  ///
  /// Llama a `GET /orders/my` con autenticación JWT.
  Future<void> loadMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/orders/my', auth: true);
      _orders = list.map((j) => OrderModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga todos los pedidos del sistema (solo administradores).
  ///
  /// Llama a `GET /orders` con autenticación JWT.
  Future<void> loadAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/orders', auth: true);
      _orders = list.map((j) => OrderModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Actualiza el estado de un pedido específico.
  ///
  /// Llama a `PUT /orders/{orderId}/status` con el [newStatus].
  /// Si es exitoso, recarga la lista completa de pedidos.
  /// Retorna `true` si la actualización fue exitosa.
  Future<bool> updateStatus(int orderId, String newStatus) async {
    try {
      await _api.put('/orders/$orderId/status', {'estado': newStatus}, auth: true);
      // Buscar el pedido actualizado y recargar la lista
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        await loadAllOrders();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
