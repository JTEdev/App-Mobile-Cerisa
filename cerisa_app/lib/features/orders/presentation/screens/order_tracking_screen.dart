import 'package:flutter/material.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';

/// Pantalla de rastreo de pedido estilo e-commerce.
///
/// Diseño con:
/// - Barra superior: ← + "Rastrear Pedido #CR-XXXX" + ⋮
/// - Tarjeta de producto con imagen, nombre, categoría, badge "En Tránsito"
/// - Timeline vertical del estado del pedido
/// - Mapa simulado con ubicación actual
/// - Botón "Contactar Soporte"
class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  /// Mapea el estado del backend al paso del timeline (0-3).
  int _currentStep() {
    switch (order.estado) {
      case 'PENDIENTE':
        return 0;
      case 'CONFIRMADO':
        return 1;
      case 'EN_PREPARACION':
        return 1;
      case 'ENVIADO':
        return 2;
      case 'ENTREGADO':
        return 3;
      case 'CANCELADO':
        return -1;
      default:
        return 0;
    }
  }

  /// Badge de estado legible en español.
  String _statusBadge() {
    switch (order.estado) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CONFIRMADO':
        return 'Confirmado';
      case 'EN_PREPARACION':
        return 'Preparando';
      case 'ENVIADO':
        return 'En Tránsito';
      case 'ENTREGADO':
        return 'Entregado';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return order.estado;
    }
  }

  /// Color del badge según estado.
  Color _badgeColor() {
    switch (order.estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'CONFIRMADO':
        return Colors.blue;
      case 'EN_PREPARACION':
        return Colors.purple;
      case 'ENVIADO':
        return AppColors.accent;
      case 'ENTREGADO':
        return AppColors.success;
      case 'CANCELADO':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Calcula la fecha estimada de entrega basándose en fecha de creación.
  String _estimatedDelivery() {
    if (order.creadoEn != null) {
      try {
        final created = DateTime.parse(order.creadoEn!);
        final delivery = created.add(const Duration(days: 5));
        return _formatShortDate(delivery);
      } catch (_) {}
    }
    final delivery = DateTime.now().add(const Duration(days: 5));
    return _formatShortDate(delivery);
  }

  String _formatShortDate(DateTime date) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatFullDate(DateTime date) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${hour == 0 ? 12 : hour}:$min $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior ──
            _buildTopBar(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider.withValues(alpha: 0.5), height: 1),
            ),

            // ── Contenido scrollable ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  // Tarjeta del producto principal
                  _buildProductCard(),
                  const SizedBox(height: 24),

                  // Timeline del estado
                  _buildOrderStatusTimeline(),
                  const SizedBox(height: 24),

                  // Mapa simulado
                  _buildMapSection(),
                  const SizedBox(height: 24),

                  // Botón contactar soporte
                  _buildContactSupport(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barra superior: ← + título + ⋮
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Seguimiento Pedido #CR-${order.id.toString().padLeft(4, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// Tarjeta del producto principal con badge de estado.
  Widget _buildProductCard() {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final badgeCol = _badgeColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Imagen placeholder del producto
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(14)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: AppColors.inputFill,
                child: const Center(child: Icon(Icons.inventory_2_rounded, size: 36, color: AppColors.primary)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        firstItem?.productoNombre ?? 'Artículo Cerisa',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeCol.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: badgeCol.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _statusBadge(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeCol),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.items.length > 1
                      ? '${order.items.length} artículos • S/ ${order.total.toStringAsFixed(2)}'
                      : 'Colección Cerisa',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Entrega Est.: ${_estimatedDelivery()}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Timeline vertical del estado del pedido.
  Widget _buildOrderStatusTimeline() {
    final step = _currentStep();
    final isCancelled = order.estado == 'CANCELADO';

    // Fechas simuladas basadas en fecha de creación
    DateTime baseDate;
    try {
      baseDate = DateTime.parse(order.creadoEn ?? DateTime.now().toIso8601String());
    } catch (_) {
      baseDate = DateTime.now();
    }

    final steps = [
      _TimelineStep(
        icon: Icons.shopping_bag_rounded,
        title: 'Pedido Realizado',
        subtitle: 'Hemos recibido tu pedido',
        date: _formatFullDate(baseDate),
        isCompleted: step >= 0 && !isCancelled,
        isActive: step == 0 && !isCancelled,
      ),
      _TimelineStep(
        icon: Icons.settings_rounded,
        title: 'Procesando',
        subtitle: 'Tu pedido ha sido preparado',
        date: step >= 1 ? _formatFullDate(baseDate.add(const Duration(hours: 28))) : '',
        isCompleted: step >= 1 && !isCancelled,
        isActive: step == 1 && !isCancelled,
      ),
      _TimelineStep(
        icon: Icons.local_shipping_rounded,
        title: 'Enviado',
        subtitle: 'Tu pedido está en camino',
        date: step >= 2 ? _formatFullDate(baseDate.add(const Duration(hours: 52))) : '',
        isCompleted: step >= 2 && !isCancelled,
        isActive: step == 2 && !isCancelled,
      ),
      _TimelineStep(
        icon: Icons.check_circle_rounded,
        title: 'Entregado',
        subtitle: 'Paquete entregado',
        date: step >= 3 ? _formatFullDate(baseDate.add(const Duration(hours: 96))) : '',
        isCompleted: step >= 3 && !isCancelled,
        isActive: step == 3 && !isCancelled,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seguimiento del Pedido',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          // Timeline
          ...List.generate(steps.length, (index) {
            final s = steps[index];
            final isLast = index == steps.length - 1;
            return _buildTimelineItem(s, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineStep step, bool isLast) {
    final textColor = step.isCompleted || step.isActive
        ? AppColors.textPrimary
        : AppColors.textSecondary.withValues(alpha: 0.6);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna del ícono y línea vertical
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Círculo con ícono
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: step.isCompleted || step.isActive ? AppColors.accent : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isCompleted || step.isActive ? AppColors.accent : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      step.icon,
                      size: 18,
                      color: step.isCompleted || step.isActive
                          ? Colors.white
                          : AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                // Línea vertical (excepto último)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: step.isCompleted
                          ? AppColors.accent.withValues(alpha: 0.4)
                          : AppColors.divider.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Contenido del paso
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: step.isActive ? FontWeight.w800 : FontWeight.w700,
                      color: step.isActive ? AppColors.accent : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: step.isCompleted || step.isActive
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                  if (step.date.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.date,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de mapa simulado con ubicación.
  Widget _buildMapSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECE4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          // Fondo del mapa simulado (líneas de calles)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(size: const Size(double.infinity, 180), painter: _MapPainter()),
          ),

          // Pin de ubicación centrado
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Text(
                    'Ubicación Actual',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          // Botón "Abrir Mapa"
          Positioned(
            bottom: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text(
                    'Abrir Mapa',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón de contactar soporte.
  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headset_mic_rounded, size: 20, color: AppColors.textSecondary),
          SizedBox(width: 10),
          Text(
            'Contactar Soporte',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Modelo interno para los pasos del timeline.
class _TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String date;
  final bool isCompleted;
  final bool isActive;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
    required this.isActive,
  });
}

/// CustomPainter para simular un mapa con líneas de calles.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Líneas diagonales simulando calles
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.9), Offset(size.width * 0.9, size.height * 0.1), paint);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.95), Offset(size.width * 0.95, size.height * 0.3), paint);

    // Líneas horizontales y verticales
    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), lightPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), lightPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), lightPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
