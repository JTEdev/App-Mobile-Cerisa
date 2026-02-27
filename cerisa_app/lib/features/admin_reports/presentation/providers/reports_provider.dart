import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';

/// Modelo de datos que representa un reporte de ventas (diario o mensual).
///
/// Contiene información del período, total de pedidos,
/// total de ventas y los productos más vendidos.
class ReportModel {
  /// Descripción del período del reporte (ej: "2024-01-15", "Enero 2024").
  final String periodo;

  /// Número total de pedidos en el período.
  final int totalPedidos;

  /// Monto total de ventas en soles del período.
  final double totalVentas;

  /// Lista de los productos más vendidos en el período.
  final List<TopProductModel> topProductos;

  /// Constructor del modelo de reporte.
  ReportModel({
    required this.periodo,
    required this.totalPedidos,
    required this.totalVentas,
    required this.topProductos,
  });

  /// Crea una instancia de [ReportModel] a partir de un mapa JSON.
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      periodo: json['periodo'] as String? ?? '',
      totalPedidos: json['totalPedidos'] as int? ?? 0,
      totalVentas: (json['totalVentas'] as num?)?.toDouble() ?? 0,
      topProductos: (json['topProductos'] as List<dynamic>?)?.map((j) => TopProductModel.fromJson(j)).toList() ?? [],
    );
  }
}

/// Modelo de datos para un producto destacado en el ranking de ventas.
///
/// Representa un producto con su cantidad total vendida,
/// usado en reportes de "Top Productos".
class TopProductModel {
  /// ID del producto.
  final int productoId;

  /// Nombre del producto.
  final String productoNombre;

  /// Cantidad total de unidades vendidas.
  final int totalVendido;

  /// Constructor del modelo de producto destacado.
  TopProductModel({required this.productoId, required this.productoNombre, required this.totalVendido});

  /// Crea una instancia de [TopProductModel] a partir de un mapa JSON.
  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      totalVendido: json['totalVendido'] as int,
    );
  }
}

/// Provider que gestiona la carga y el estado de los reportes de ventas.
///
/// Proporciona acceso a reportes diarios, mensuales y la lista
/// de productos más vendidos. Incluye un método [loadAll] que
/// carga los tres endpoints en paralelo para mayor eficiencia.
class ReportsProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el backend.
  final ApiService _api;

  /// Constructor que recibe el servicio de API.
  ReportsProvider(this._api);

  /// Reporte diario cargado desde el servidor.
  ReportModel? _dailyReport;

  /// Reporte mensual cargado desde el servidor.
  ReportModel? _monthlyReport;

  /// Lista de productos más vendidos.
  List<TopProductModel> _topProducts = [];

  /// Indica si hay una operación de carga en curso.
  bool _isLoading = false;

  /// Mensaje de error de la última operación fallida.
  String? _error;

  /// Reporte diario (solo lectura).
  ReportModel? get dailyReport => _dailyReport;

  /// Reporte mensual (solo lectura).
  ReportModel? get monthlyReport => _monthlyReport;

  /// Lista de productos más vendidos (solo lectura).
  List<TopProductModel> get topProducts => _topProducts;

  /// Indica si hay una carga en curso.
  bool get isLoading => _isLoading;

  /// Mensaje de error actual.
  String? get error => _error;

  /// Carga el reporte diario desde `GET /reports/daily`.
  Future<void> loadDailyReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/reports/daily', auth: true);
      _dailyReport = ReportModel.fromJson(data);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga el reporte mensual desde `GET /reports/monthly`.
  Future<void> loadMonthlyReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/reports/monthly', auth: true);
      _monthlyReport = ReportModel.fromJson(data);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga la lista de productos más vendidos desde `GET /reports/top-products`.
  Future<void> loadTopProducts() async {
    try {
      final list = await _api.getList('/reports/top-products', auth: true);
      _topProducts = list.map((j) => TopProductModel.fromJson(j)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Carga todos los reportes en paralelo para mayor eficiencia.
  ///
  /// Ejecuta simultáneamente las peticiones a los tres endpoints:
  /// - `GET /reports/daily` (reporte diario)
  /// - `GET /reports/monthly` (reporte mensual)
  /// - `GET /reports/top-products` (productos más vendidos)
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ejecutar las tres peticiones en paralelo con Future.wait
      final results = await Future.wait([
        _api.get('/reports/daily', auth: true),
        _api.get('/reports/monthly', auth: true),
        _api.getList('/reports/top-products', auth: true),
      ]);
      _dailyReport = ReportModel.fromJson(results[0] as Map<String, dynamic>);
      _monthlyReport = ReportModel.fromJson(results[1] as Map<String, dynamic>);
      _topProducts = (results[2] as List<dynamic>).map((j) => TopProductModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
