import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';

/// Modelo de datos que representa un reporte de ventas (diario, mensual o anual).
class ReportModel {
  final String periodo;
  final int totalPedidos;
  final double totalVentas;
  final double ventasAnterior;
  final List<TopProductModel> topProductos;

  ReportModel({
    required this.periodo,
    required this.totalPedidos,
    required this.totalVentas,
    required this.ventasAnterior,
    required this.topProductos,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      periodo: json['periodo'] as String? ?? '',
      totalPedidos: json['totalPedidos'] as int? ?? 0,
      totalVentas: (json['totalVentas'] as num?)?.toDouble() ?? 0,
      ventasAnterior: (json['ventasAnterior'] as num?)?.toDouble() ?? 0,
      topProductos: (json['topProductos'] as List<dynamic>?)?.map((j) => TopProductModel.fromJson(j)).toList() ?? [],
    );
  }

  /// Porcentaje de crecimiento respecto al per\u00edodo anterior.
  double get growthPercent {
    if (ventasAnterior <= 0) return totalVentas > 0 ? 100.0 : 0.0;
    return ((totalVentas - ventasAnterior) / ventasAnterior) * 100;
  }
}

class TopProductModel {
  final int productoId;
  final String productoNombre;
  final int totalVendido;

  TopProductModel({required this.productoId, required this.productoNombre, required this.totalVendido});

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      totalVendido: json['totalVendido'] as int,
    );
  }
}

/// Provider que gestiona la carga y el estado de los reportes de ventas.
class ReportsProvider extends ChangeNotifier {
  final ApiService _api;

  ReportsProvider(this._api);

  ReportModel? _dailyReport;
  ReportModel? _monthlyReport;
  ReportModel? _yearlyReport;
  List<TopProductModel> _topProducts = [];
  Map<String, double> _weeklyTrend = {};
  bool _isLoading = false;
  String? _error;

  ReportModel? get dailyReport => _dailyReport;
  ReportModel? get monthlyReport => _monthlyReport;
  ReportModel? get yearlyReport => _yearlyReport;
  List<TopProductModel> get topProducts => _topProducts;
  Map<String, double> get weeklyTrend => _weeklyTrend;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Devuelve el reporte para el per\u00edodo solicitado (0=d\u00eda, 1=mes, 2=a\u00f1o).
  ReportModel? reportForPeriod(int periodIndex) {
    switch (periodIndex) {
      case 0:
        return _dailyReport;
      case 1:
        return _monthlyReport;
      case 2:
        return _yearlyReport;
      default:
        return _monthlyReport;
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.get('/reports/daily', auth: true),
        _api.get('/reports/monthly', auth: true),
        _api.get('/reports/yearly', auth: true),
        _api.getList('/reports/top-products', auth: true),
        _api.get('/reports/weekly-trend', auth: true),
      ]);
      _dailyReport = ReportModel.fromJson(results[0] as Map<String, dynamic>);
      _monthlyReport = ReportModel.fromJson(results[1] as Map<String, dynamic>);
      _yearlyReport = ReportModel.fromJson(results[2] as Map<String, dynamic>);
      _topProducts = (results[3] as List<dynamic>).map((j) => TopProductModel.fromJson(j)).toList();
      final trendRaw = results[4] as Map<String, dynamic>;
      _weeklyTrend = trendRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
