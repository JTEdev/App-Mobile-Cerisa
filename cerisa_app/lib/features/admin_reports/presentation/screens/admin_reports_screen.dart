import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/widgets/common_widgets.dart';
import 'package:cerisa_app/features/admin_reports/presentation/providers/reports_provider.dart';

/// Pantalla de reportes de ventas para el administrador.
///
/// Muestra tres secciones principales:
/// 1. Reporte Diario: pedidos y ventas del día actual.
/// 2. Reporte Mensual: pedidos y ventas del mes actual.
/// 3. Top Productos: ranking de productos más vendidos del mes.
///
/// Los datos se cargan en paralelo mediante [ReportsProvider.loadAll].
class AdminReportsScreen extends StatefulWidget {
  /// Constructor constante.
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

/// Estado de [AdminReportsScreen].
class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar todos los reportes al inicializar
    Future.microtask(() => context.read<ReportsProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          // Estados de carga y error
          if (provider.isLoading) return const AppLoadingIndicator();
          if (provider.error != null) {
            return AppErrorWidget(message: provider.error!, onRetry: () => provider.loadAll());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAll(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Sección: Reporte Diario
                if (provider.dailyReport != null) ...[
                  const Text('Reporte Diario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ReportCard(
                    periodo: provider.dailyReport!.periodo,
                    pedidos: provider.dailyReport!.totalPedidos,
                    ventas: provider.dailyReport!.totalVentas,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                ],

                // Sección: Reporte Mensual
                if (provider.monthlyReport != null) ...[
                  const Text('Reporte Mensual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ReportCard(
                    periodo: provider.monthlyReport!.periodo,
                    pedidos: provider.monthlyReport!.totalPedidos,
                    ventas: provider.monthlyReport!.totalVentas,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                ],

                // Sección: Top Productos del Mes
                const Text('Top Productos del Mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (provider.topProducts.isEmpty)
                  // Mensaje cuando no hay datos de ventas
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No hay datos de ventas aún',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  // Lista de productos más vendidos con ranking
                  ...provider.topProducts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        // Avatar con posición en el ranking (dorado para top 3)
                        leading: CircleAvatar(
                          backgroundColor: i < 3
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: i < 3 ? Colors.amber[800] : Colors.grey,
                            ),
                          ),
                        ),
                        // Nombre del producto
                        title: Text(p.productoNombre),
                        // Cantidad vendida
                        trailing: Text(
                          '${p.totalVendido} vendidos',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget de tarjeta reutilizable para mostrar un resumen de reporte.
///
/// Muestra el período, número de pedidos y monto total de ventas
/// en un diseño de dos columnas con íconos coloreados.
class _ReportCard extends StatelessWidget {
  /// Descripción del período del reporte.
  final String periodo;

  /// Número total de pedidos.
  final int pedidos;

  /// Monto total de ventas en soles.
  final double ventas;

  /// Color temático de la tarjeta.
  final Color color;

  /// Constructor constante de la tarjeta de reporte.
  const _ReportCard({required this.periodo, required this.pedidos, required this.ventas, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etiqueta del período
            Text(periodo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                // Columna izquierda: total de pedidos
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, color: color, size: 32),
                      const SizedBox(height: 4),
                      Text('$pedidos', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Pedidos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                // Separador vertical entre columnas
                Container(width: 1, height: 50, color: Colors.grey[300]),
                // Columna derecha: total de ventas
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.attach_money, color: color, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        'S/ ${ventas.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Ventas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
