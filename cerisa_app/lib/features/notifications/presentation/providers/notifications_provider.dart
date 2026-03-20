import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';

/// Modelo de notificación que mapea la respuesta del API.
class NotificationModel {
  final int id;
  final String tipo;
  final String titulo;
  final String cuerpo;
  final bool leida;
  final int? referenciaId;
  final String? creadoEn;

  NotificationModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    required this.leida,
    this.referenciaId,
    this.creadoEn,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      titulo: json['titulo'] as String,
      cuerpo: (json['cuerpo'] as String?) ?? '',
      leida: json['leida'] as bool? ?? false,
      referenciaId: json['referenciaId'] as int?,
      creadoEn: json['creadoEn'] as String?,
    );
  }
}

/// Provider que gestiona las notificaciones del vendedor.
class NotificationsProvider extends ChangeNotifier {
  final ApiService _api;

  NotificationsProvider(this._api);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  /// Carga todas las notificaciones desde el API.
  Future<void> loadNotifications({bool force = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/notifications', auth: true);
      _notifications = list
          .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
          .toList();
      _unreadCount = _notifications.where((n) => !n.leida).length;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Obtiene solo el conteo de no leídas (ligero).
  Future<void> loadUnreadCount() async {
    try {
      final data = await _api.get('/notifications/unread-count', auth: true);
      _unreadCount = (data['count'] as num).toInt();
      notifyListeners();
    } catch (_) {}
  }

  /// Marcar todas como leídas.
  Future<void> markAllRead() async {
    try {
      await _api.put('/notifications/read-all', {}, auth: true);
      for (int i = 0; i < _notifications.length; i++) {
        final n = _notifications[i];
        if (!n.leida) {
          _notifications[i] = NotificationModel(
            id: n.id,
            tipo: n.tipo,
            titulo: n.titulo,
            cuerpo: n.cuerpo,
            leida: true,
            referenciaId: n.referenciaId,
            creadoEn: n.creadoEn,
          );
        }
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Marcar una notificación individual como leída.
  Future<void> markRead(int id) async {
    try {
      await _api.put('/notifications/$id/read', {}, auth: true);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        final n = _notifications[idx];
        _notifications[idx] = NotificationModel(
          id: n.id,
          tipo: n.tipo,
          titulo: n.titulo,
          cuerpo: n.cuerpo,
          leida: true,
          referenciaId: n.referenciaId,
          creadoEn: n.creadoEn,
        );
        _unreadCount = _notifications.where((n) => !n.leida).length;
        notifyListeners();
      }
    } catch (_) {}
  }
}
