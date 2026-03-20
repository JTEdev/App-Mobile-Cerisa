import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedFilter = 'TODOS';
  int _expandedIndex = -1;

  final _filterStatuses = ['TODOS', 'PENDIENTE', 'CONFIRMADO', 'EN_PREPARACION', 'ENVIADO', 'ENTREGADO'];
  final _allStatuses = ['PENDIENTE', 'CONFIRMADO', 'EN_PREPARACION', 'ENVIADO', 'ENTREGADO', 'CANCELADO'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrdersProvider>().loadAllOrders());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'CONFIRMADO':
        return Colors.blue;
      case 'EN_PREPARACION':
        return const Color(0xFF7E57C2);
      case 'ENVIADO':
        return Colors.teal;
      case 'ENTREGADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CONFIRMADO':
        return 'Confirmado';
      case 'EN_PREPARACION':
        return 'En Preparación';
      case 'ENVIADO':
        return 'Enviado';
      case 'ENTREGADO':
        return 'Entregado';
      case 'CANCELADO':
        return 'Anulado';
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'TODOS':
        return Icons.list_alt_rounded;
      case 'PENDIENTE':
        return Icons.access_time_rounded;
      case 'CONFIRMADO':
        return Icons.check_circle_outline_rounded;
      case 'EN_PREPARACION':
        return Icons.restaurant_rounded;
      case 'ENVIADO':
        return Icons.local_shipping_rounded;
      case 'ENTREGADO':
        return Icons.done_all_rounded;
      default:
        return Icons.circle;
    }
  }

  String _filterLabel(String status) {
    switch (status) {
      case 'TODOS':
        return 'Todos';
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CONFIRMADO':
        return 'Confirmado';
      case 'EN_PREPARACION':
        return 'Preparando';
      case 'ENVIADO':
        return 'Enviado';
      case 'ENTREGADO':
        return 'Entregado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          _buildFilterTabs(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cerisa Artesanal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Gestión de Pedidos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _filterStatuses.map((status) {
            final isActive = _selectedFilter == status;
            final color = status == 'TODOS' ? AppColors.primary : _statusColor(status);
            return GestureDetector(
              onTap: () => setState(() {
                _selectedFilter = status;
                _expandedIndex = -1;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 56 : 46,
                      height: isActive ? 56 : 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? color : Colors.white,
                        border: Border.all(
                          color: isActive ? color : AppColors.divider,
                          width: isActive ? 2.5 : 1.5,
                        ),
                        boxShadow: isActive
                            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Icon(
                        _statusIcon(status),
                        size: isActive ? 26 : 22,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _filterLabel(status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const AppLoadingIndicator();
        if (provider.error != null) return AppErrorWidget(message: provider.error!);
        final allOrders = provider.orders;
        if (allOrders.isEmpty) return const AppEmptyWidget(message: 'No hay pedidos');

        final orders = _selectedFilter == 'TODOS'
            ? allOrders
            : allOrders.where((o) => o.estado == _selectedFilter).toList();

        if (orders.isEmpty) {
          return AppEmptyWidget(message: 'No hay pedidos en estado ${_filterLabel(_selectedFilter).toLowerCase()}');
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadAllOrders(force: true),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final isExpanded = _expandedIndex == index;
              return _buildOrderCard(order, index, isExpanded, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, int index, bool isExpanded, OrdersProvider provider) {
    final statusColor = _statusColor(order.estado);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isExpanded ? Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? 0.08 : 0.04),
            blurRadius: isExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Nro', style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w500)),
                        Text('${order.id}', style: TextStyle(fontSize: 16, color: statusColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clienteNombre,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(order.clienteEmail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel(order.estado),
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'S/ ${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 26),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedDetail(order, provider),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(OrderModel order, OrdersProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('Detalle del Pedido', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text('${item.productoNombre} x${item.cantidad}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                Text('S/ ${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          )),
          if (order.direccionEntrega != null && order.direccionEntrega!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dirección de entrega', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(order.direccionEntrega!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (order.notas != null && order.notas!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_alt_rounded, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(child: Text(order.notas!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('Marcar Nuevo Estado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allStatuses.map((status) {
              final isActive = order.estado == status;
              final isCancel = status == 'CANCELADO';
              final color = _statusColor(status);
              return GestureDetector(
                onTap: isActive ? null : () async {
                  final ok = await provider.updateStatus(order.id, status);
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.error ?? 'Error al actualizar'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? color.withValues(alpha: 0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? color : (isCancel ? Colors.red.withValues(alpha: 0.4) : AppColors.divider),
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive) ...[
                        Icon(Icons.check_circle, size: 16, color: color),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        status == 'CANCELADO' ? 'ANULAR' : _statusLabel(status).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCancel && !isActive ? Colors.red : (isActive ? color : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
