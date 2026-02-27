import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';

/// Pantalla que muestra el historial de pedidos del usuario actual.
///
/// Cada pedido se muestra como una tarjeta tappeable que lleva
/// directamente a la pantalla de rastreo.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrdersProvider>().loadMyOrders());
  }

  Color _statusColor(String estado) {
    switch (estado) {
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
        return Colors.grey;
    }
  }

  String _statusLabel(String estado) {
    switch (estado) {
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
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Historial de Pedidos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.search, color: AppColors.accent, size: 26),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider.withValues(alpha: 0.5), height: 1),
            ),
            // ── Tabs de filtro (mock) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildTab('Todos', true),
                  _buildTab('En Tránsito', false),
                  _buildTab('Entregados', false),
                  _buildTab('Cancelados', false),
                ],
              ),
            ),
            // ── Contenido ──
            Expanded(
              child: Consumer<OrdersProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return const AppLoadingIndicator();
                  if (provider.error != null) {
                    return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadMyOrders());
                  }
                  if (provider.orders.isEmpty) {
                    return const AppEmptyWidget(message: 'No orders yet', icon: Icons.receipt_long_outlined);
                  }

                  // Agrupar pedidos por fecha (últimos 2 meses = recientes)
                  final now = DateTime.now();
                  final recent = provider.orders.where((o) {
                    final date = DateTime.tryParse(o.creadoEn ?? '') ?? now;
                    return date.isAfter(now.subtract(Duration(days: 60)));
                  }).toList();
                  final older = provider.orders.where((o) {
                    final date = DateTime.tryParse(o.creadoEn ?? '') ?? now;
                    return date.isBefore(now.subtract(Duration(days: 60)));
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () => provider.loadMyOrders(),
                    color: AppColors.accent,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      children: [
                        if (recent.isNotEmpty) ...[
                          const Text(
                            'PEDIDOS RECIENTES',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...recent.map(_buildOrderCard),
                          const SizedBox(height: 24),
                        ],
                        if (older.isNotEmpty) ...[
                          const Text(
                            'PEDIDOS ANTERIORES',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...older.map(_buildOrderCard),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final date = DateTime.tryParse(order.creadoEn ?? '') ?? DateTime.now();
    final formattedDate = '${_monthShortEs(date.month)} ${date.day}, ${date.year}';
    final price = 'S/ ${order.total.toStringAsFixed(2)}';
    final badge = _statusLabel(order.estado);
    final badgeColor = _statusColor(order.estado);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: firstItem != null && firstItem.productoNombre.contains('pan')
                    ? Image.network(
                        'https://images.unsplash.com/photo-1519864600265-abb7f27c4c2c?auto=format&fit=crop&w=64&q=80',
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.inventory_2_rounded, size: 32, color: AppColors.primary),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #CR-${order.id}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(formattedDate, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        Text(
                          price,
                          style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusDot(badgeColor),
                        const SizedBox(width: 6),
                        Text(
                          badge.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Flecha
            Padding(
              padding: const EdgeInsets.only(top: 32, right: 16),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.divider),
            ),
          ],
        ),
      ),
    );
  }

  // _monthShort eliminado (no usado)
  String _monthShortEs(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  Widget _buildStatusDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
