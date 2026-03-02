import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';

/// Pantalla de administración de pedidos.
///
/// Permite al administrador ver todos los pedidos del sistema,
/// con información detallada de cada uno (cliente, productos,
/// dirección, notas). Incluye funcionalidad para cambiar el
/// estado de un pedido mediante chips de selección.
class AdminOrdersScreen extends StatefulWidget {
  /// Constructor constante.
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

/// Estado de [AdminOrdersScreen].
class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar todos los pedidos del sistema al iniciar
    Future.microtask(() => context.read<OrdersProvider>().loadAllOrders());
  }

  /// Lista de todos los estados posibles de un pedido.
  final _statuses = ['PENDIENTE', 'CONFIRMADO', 'EN_PREPARACION', 'ENVIADO', 'ENTREGADO', 'CANCELADO'];

  /// Devuelve el color asociado a cada estado de pedido.
  Color _statusColor(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'CONFIRMADO':
        return Colors.blue;
      case 'EN_PREPARACION':
        return Colors.purple;
      case 'ENVIADO':
        return Colors.indigo;
      case 'ENTREGADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Convierte el código de estado a una etiqueta legible en español.
  String _statusLabel(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'CONFIRMADO':
        return 'Confirmado';
      case 'EN_PREPARACION':
        return 'En preparación';
      case 'ENVIADO':
        return 'Enviado';
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
      appBar: AppBar(title: const Text('Gestión Pedidos')),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          // Estados de carga, error y lista vacía
          if (provider.isLoading) return const AppLoadingIndicator();
          if (provider.error != null) {
            return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadAllOrders(force: true));
          }
          if (provider.orders.isEmpty) {
            return const AppEmptyWidget(message: 'No hay pedidos', icon: Icons.receipt_long_outlined);
          }

          // Lista de pedidos con pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => provider.loadAllOrders(force: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    // Avatar con número de pedido coloreado según estado
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(order.estado).withValues(alpha: 0.15),
                      child: Text(
                        '#${order.id}',
                        style: TextStyle(fontSize: 12, color: _statusColor(order.estado), fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Nombre del cliente
                    title: Text(order.clienteNombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email del cliente
                        Text(order.clienteEmail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Badge del estado actual
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(order.estado).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusLabel(order.estado),
                                style: TextStyle(
                                  color: _statusColor(order.estado),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Total del pedido
                            Text(
                              'S/ ${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Contenido expandido: detalles y cambio de estado
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sección: Productos del pedido
                            const Text('Productos:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...order.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('${item.productoNombre} x${item.cantidad}')),
                                    Text('S/ ${item.subtotal.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ),

                            // Dirección de entrega (si existe)
                            if (order.direccionEntrega != null && order.direccionEntrega!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(order.direccionEntrega!, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ],

                            // Notas del cliente (si existen)
                            if (order.notas != null && order.notas!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.note, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(order.notas!, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ],

                            const SizedBox(height: 12),
                            // Sección: Cambiar estado del pedido mediante ChoiceChips
                            const Text('Cambiar estado:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _statuses.map((status) {
                                final isActive = order.estado == status;
                                return ChoiceChip(
                                  label: Text(_statusLabel(status), style: const TextStyle(fontSize: 11)),
                                  selected: isActive,
                                  selectedColor: _statusColor(status).withValues(alpha: 0.3),
                                  // Deshabilitado si ya tiene ese estado
                                  onSelected: isActive
                                      ? null
                                      : (_) async {
                                          // Intentar actualizar el estado en el servidor
                                          final ok = await provider.updateStatus(order.id, status);
                                          if (!ok && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(provider.error ?? 'Error'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
