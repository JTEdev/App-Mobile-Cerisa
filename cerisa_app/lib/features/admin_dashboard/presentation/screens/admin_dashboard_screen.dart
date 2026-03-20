import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:cerisa_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:cerisa_app/features/admin_reports/presentation/providers/reports_provider.dart';

/// Pantalla de inicio del panel de administración.
///
/// Muestra un dashboard con métricas de ventas, tendencia semanal,
/// nivel del vendedor y accesos rápidos a la gestión operativa.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final rp = context.read<ReportsProvider>();
      if (rp.dailyReport == null && !rp.isLoading) {
        Future.microtask(() => rp.loadAll());
      }
    }
  }

  /// Formatea un número como moneda ($1,240.00)
  String _formatCurrency(double amount) {
    final f = NumberFormat('#,##0.00', 'en_US');
    return '\$${f.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName ?? 'Admin';
    // Obtener solo el primer nombre
    final firstName = userName.split(' ').first;

    // Cargar conteo de notificaciones no leídas
    final notifProvider = context.watch<NotificationsProvider>();
    if (notifProvider.unreadCount == 0 && !notifProvider.isLoading) {
      Future.microtask(() => notifProvider.loadUnreadCount());
    }

    final rp = context.watch<ReportsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar + Header ──
          SliverToBoxAdapter(child: _buildHeader(context, firstName)),
          // ── Dashboard Cards ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildVentasHoyCard(rp),
                const SizedBox(height: 12),
                _buildTendenciaSemanalCard(rp),
                const SizedBox(height: 12),
                _buildEstadoActualCard(rp),
                const SizedBox(height: 24),
                _buildSeccionGestionOperativa(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Header con gradiente oscuro, saludo y acciones
  Widget _buildHeader(BuildContext context, String firstName) {
    final unread = context.watch<NotificationsProvider>().unreadCount;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3E2C1C), Color(0xFF5D3F24)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior con logo, campana y avatar
              Row(
                children: [
                  // Menú hamburguesa
                  const Icon(Icons.menu, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Cerisa',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  // Campana de notificaciones
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin/notifications'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                          if (unread > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Color(0xFFE8734A), shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      color: AppColors.accent,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Saludo
              Text(
                'Hola, $firstName!',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Panel de control de alta eficiencia.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarjeta "Ventas hoy" con monto, porcentaje, meta y barra de progreso
  Widget _buildVentasHoyCard(ReportsProvider rp) {
    final daily = rp.dailyReport;
    final ventas = daily?.totalVentas ?? 0;
    final monthly = rp.monthlyReport;
    final metaMensual = monthly != null && monthly.totalVentas > 0
        ? monthly.totalVentas * 1.2 // meta = 120% de ventas mes actual
        : 5000.0;
    // Meta diaria proporcional: metaMensual / días del mes
    final diasMes = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    final metaDiaria = metaMensual / diasMes;
    final porcentaje = metaDiaria > 0 ? (ventas / metaDiaria).clamp(0.0, 1.0) : 0.0;
    final porcentajeInt = (porcentaje * 100).round();
    final growth = daily?.growthPercent ?? 0;
    final growthPositive = growth >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: icono + titulo + badge EN VIVO
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8734A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.point_of_sale, color: Color(0xFFE8734A), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Ventas hoy',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const Spacer(),
              // Badge EN VIVO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8734A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EN VIVO',
                      style: TextStyle(color: Color(0xFFE8734A), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Monto principal + tendencia
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(ventas),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const Spacer(),
              // Tendencia
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (growthPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      growthPositive ? Icons.trending_up : Icons.trending_down,
                      color: growthPositive ? AppColors.success : AppColors.error,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${growthPositive ? '+' : ''}${growth.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: growthPositive ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Meta y porcentaje
          Row(
            children: [
              const Spacer(),
              Text(
                'META: ${_formatCurrency(metaDiaria)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Spacer(),
              Text(
                '$porcentajeInt%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: porcentajeInt >= 100 ? AppColors.success : const Color(0xFFE8734A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8734A)),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta "Tendencia Semanal" con monto y gráfico de barras
  Widget _buildTendenciaSemanalCard(ReportsProvider rp) {
    final trend = rp.weeklyTrend;
    final totalSemanal = trend.values.fold<double>(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Lado izquierdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DBE).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.insights, color: Color(0xFF5B8DBE), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Tendencia Semanal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _formatCurrency(totalSemanal),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          // Gráfico de barras mini
          _buildMiniBarChart(trend),
        ],
      ),
    );
  }

  /// Mini gráfico de barras basado en datos reales de tendencia semanal
  Widget _buildMiniBarChart(Map<String, double> trend) {
    final values = trend.values.toList();
    if (values.isEmpty) {
      return const SizedBox(width: 80, height: 56);
    }
    final maxVal = values.reduce(math.max);
    const maxH = 48.0;

    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final h = maxVal > 0 ? (values[i] / maxVal) * maxH : 4.0;
          final color = i % 2 == 0 ? const Color(0xFFE8734A) : AppColors.success;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 10,
              height: math.max(h, 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Tarjeta "Estado Actual" — nivel basado en ventas mensuales reales
  Widget _buildEstadoActualCard(ReportsProvider rp) {
    final ventasMes = rp.monthlyReport?.totalVentas ?? 0;
    // Niveles por rangos de ventas mensuales
    String nivel;
    String proximoNivel;
    double metaProxima;
    Color nivelColor;
    if (ventasMes >= 50000) {
      nivel = 'Nivel Diamante';
      proximoNivel = '';
      metaProxima = 0;
      nivelColor = const Color(0xFF5B8DBE);
    } else if (ventasMes >= 20000) {
      nivel = 'Nivel Pro';
      proximoNivel = 'Diamante';
      metaProxima = 50000;
      nivelColor = const Color(0xFF5B8DBE);
    } else if (ventasMes >= 5000) {
      nivel = 'Nivel Avanzado';
      proximoNivel = 'Pro';
      metaProxima = 20000;
      nivelColor = AppColors.success;
    } else {
      nivel = 'Nivel Básico';
      proximoNivel = 'Avanzado';
      metaProxima = 5000;
      nivelColor = const Color(0xFFE8734A);
    }
    final faltante = metaProxima > ventasMes ? metaProxima - ventasMes : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Icono estrella
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: nivelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.star_rounded, color: nivelColor, size: 24),
          ),
          const SizedBox(width: 14),
          // Textos: Estado Actual / Nivel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado Actual',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  nivel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          // Próximo bono o logro máximo
          if (proximoNivel.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'PRÓXIMO: $proximoNivel'.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatCurrency(faltante)} faltantes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: nivelColor.withValues(alpha: 0.9),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: nivelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '¡MÁXIMO!',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: nivelColor),
              ),
            ),
        ],
      ),
    );
  }

  /// Sección "GESTIÓN OPERATIVA" con los tiles de acceso rápido
  Widget _buildSeccionGestionOperativa(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GESTIÓN OPERATIVA',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        _buildGestionTile(
          icon: Icons.trending_up,
          iconColor: const Color(0xFFE8734A),
          iconBgColor: const Color(0xFFE8734A).withValues(alpha: 0.12),
          titulo: 'Registrar Ventas',
          subtitulo: 'Carga nuevas transacciones y pedidos hoy.',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.registerSale);
          },
        ),
        const SizedBox(height: 10),
        _buildGestionTile(
          icon: Icons.description_outlined,
          iconColor: AppColors.success,
          iconBgColor: AppColors.success.withValues(alpha: 0.12),
          titulo: 'Catálogo Productos',
          subtitulo: 'Edita precios, fotos y descripciones de artículos.',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminProducts);
          },
        ),
        const SizedBox(height: 10),
        _buildGestionTile(
          icon: Icons.warehouse_outlined,
          iconColor: const Color(0xFFE8734A),
          iconBgColor: const Color(0xFFE8734A).withValues(alpha: 0.12),
          titulo: 'Inventario y Stock',
          subtitulo: 'Control de existencias y alertas de reposición.',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminStock);
          },
        ),
        const SizedBox(height: 10),
        _buildGestionTile(
          icon: Icons.people_outline,
          iconColor: const Color(0xFF5B8DBE),
          iconBgColor: const Color(0xFF5B8DBE).withValues(alpha: 0.12),
          titulo: 'Base de Clientes',
          subtitulo: 'Seguimiento de pedidos y datos de contacto.',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminUsers);
          },
        ),
        const SizedBox(height: 10),
        _buildGestionTile(
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF3E2C1C),
          iconBgColor: const Color(0xFF3E2C1C).withValues(alpha: 0.1),
          titulo: 'Reportes Mensuales',
          subtitulo: 'Análisis detallado de rentabilidad y metas.',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.adminReports);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Tile individual de gestión operativa
  Widget _buildGestionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(Icons.chevron_right, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
