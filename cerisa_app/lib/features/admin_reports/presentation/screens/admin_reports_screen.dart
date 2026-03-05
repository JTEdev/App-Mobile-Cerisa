import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/admin_reports/presentation/providers/reports_provider.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';

// ─────────────────────────────────────────────────────────────
// Constantes de color
// ─────────────────────────────────────────────────────────────
const _kOrange = Color(0xFFE8734A);
const _kGreen = Color(0xFF27AE60);
const _kAmber = Color(0xFFF5A623);
const _kRed = Color(0xFFE74C3C);
const _kDarkBrown = Color(0xFF3E2C1C);

/// Pantalla de "Reportes" para el vendedor.
///
/// Muestra estado general (ingresos, pedidos hoy, inventario),
/// productos estrella, tendencia semanal con gráfico de barras
/// y selector de período (DÍA / MES / AÑO).
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  int _periodIndex = 1; // 0=DÍA, 1=MES, 2=AÑO
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReportsProvider>().loadAll();
      // Cargar datos complementarios si están disponibles
      try {
        context.read<CatalogProvider>().loadProducts();
      } catch (_) {}
      try {
        context.read<OrdersProvider>().loadAllOrders();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ReportsProvider>(
          builder: (context, rp, _) {
            return RefreshIndicator(
              color: _kOrange,
              onRefresh: () => rp.loadAll(),
              child: CustomScrollView(
                slivers: [
                  // ── Header ──
                  SliverToBoxAdapter(child: _buildHeader()),
                  // ── Period selector ──
                  SliverToBoxAdapter(child: _buildPeriodSelector()),
                  // ── Estado General header ──
                  SliverToBoxAdapter(child: _buildSectionHeader('ESTADO GENERAL', dark: true)),
                  // ── Metric cards ──
                  SliverToBoxAdapter(child: _buildEstadoGeneral(rp)),
                  // ── Productos Estrella ──
                  SliverToBoxAdapter(child: _buildProductosEstrella(rp)),
                  // ── Tendencia Semanal ──
                  SliverToBoxAdapter(child: _buildTendenciaSemanal(rp)),
                  // Bottom padding
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          const Text(
            'Reportes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _kOrange.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined, color: _kOrange, size: 20),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PERIOD SELECTOR: DÍA | MES | AÑO  +  Año
  // ─────────────────────────────────────────────────────────────

  Widget _buildPeriodSelector() {
    const labels = ['DÍA', 'MES', 'AÑO'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          // Periodo pills
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(labels.length, (i) {
                final selected = _periodIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _periodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _kOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          // Separador
          Container(width: 1, height: 24, color: AppColors.divider.withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          // Año pill
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedYear = _selectedYear == DateTime.now().year ? DateTime.now().year - 1 : DateTime.now().year;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: _kDarkBrown, borderRadius: BorderRadius.circular(24)),
              child: Text(
                '$_selectedYear',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION HEADER (dark strip)
  // ─────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {bool dark = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: dark ? _kDarkBrown : Colors.transparent,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: dark ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ESTADO GENERAL: 3 metric cards
  // ─────────────────────────────────────────────────────────────

  Widget _buildEstadoGeneral(ReportsProvider rp) {
    // Datos del reporte mensual
    final monthly = rp.monthlyReport;
    final totalVentas = monthly?.totalVentas ?? 0.0;
    final totalPedidos = monthly?.totalPedidos ?? 0;

    // Datos del reporte diario para "Pedidos Hoy"
    final daily = rp.dailyReport;
    final pedidosHoy = daily?.totalPedidos ?? 0;

    // Inventario: contar productos sin stock
    int productosSinStock = 0;
    String inventarioLabel = 'Normal';
    Color inventarioColor = _kGreen;
    IconData inventarioIcon = Icons.check_circle;
    Color inventarioIconBg = _kGreen;
    try {
      final catalog = context.read<CatalogProvider>();
      productosSinStock = catalog.products.where((p) => p.stock <= 0).length;
    } catch (_) {}

    if (productosSinStock >= 3) {
      inventarioLabel = 'Crítico';
      inventarioColor = _kRed;
      inventarioIcon = Icons.error;
      inventarioIconBg = _kRed;
    } else if (productosSinStock >= 1) {
      inventarioLabel = 'Atención';
      inventarioColor = _kAmber;
      inventarioIcon = Icons.warning_rounded;
      inventarioIconBg = _kAmber;
    }

    // Pendientes de envío
    int pendientes = 0;
    try {
      final ordProv = context.read<OrdersProvider>();
      pendientes = ordProv.orders.where((o) => o.estado == 'PENDIENTE').length;
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // INGRESOS card
          _MetricCard(
            label: 'INGRESOS',
            value: '\$${_formatMoney(totalVentas)}',
            subtitle: '12% superior al mes pasado',
            subtitleColor: _kGreen,
            subtitleIcon: Icons.trending_up,
            trailingIcon: Icons.check_circle,
            trailingIconColor: _kGreen,
            accentColor: _kGreen,
          ),
          const SizedBox(height: 14),
          // PEDIDOS HOY card
          _MetricCard(
            label: 'PEDIDOS HOY',
            value: '$pedidosHoy',
            subtitle: '$pendientes pedidos pendientes de envío',
            subtitleColor: _kOrange,
            subtitleIcon: Icons.access_time,
            trailingIcon: Icons.warning_rounded,
            trailingIconColor: _kAmber,
            accentColor: _kAmber,
          ),
          const SizedBox(height: 14),
          // INVENTARIO card
          _MetricCard(
            label: 'INVENTARIO',
            value: inventarioLabel,
            subtitle: '$productosSinStock productos sin stock disponible',
            subtitleColor: inventarioColor,
            subtitleIcon: Icons.inventory_2_outlined,
            trailingIcon: inventarioIcon,
            trailingIconColor: inventarioIconBg,
            accentColor: inventarioColor,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUCTOS ESTRELLA
  // ─────────────────────────────────────────────────────────────

  Widget _buildProductosEstrella(ReportsProvider rp) {
    final topProducts = rp.topProducts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Text(
                'PRODUCTOS ESTRELLA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'MÁS VENDIDOS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _kGreen, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Product cards
          if (topProducts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: const Text(
                'No hay datos de ventas aún',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            )
          else
            ...topProducts.take(4).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              // Simulate growth % deterministic to product
              final growthPct = [15, 8, 12, 5][i % 4];
              final iconData = [
                Icons.local_florist,
                Icons.rice_bowl_outlined,
                Icons.emoji_objects_outlined,
                Icons.spa_outlined,
              ][i % 4];
              final iconBg = [_kOrange, _kRed.withValues(alpha: 0.8), _kAmber, _kGreen][i % 4];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBg.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: iconBg, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Name + units
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.productoNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${p.totalVendido} unidades vendidas',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    // Growth
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+$growthPct%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kGreen),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CRECIMIENTO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TENDENCIA SEMANAL — bar chart
  // ─────────────────────────────────────────────────────────────

  Widget _buildTendenciaSemanal(ReportsProvider rp) {
    // Datos simulados de tendencia semanal
    final monthly = rp.monthlyReport;
    final baseValue = (monthly?.totalVentas ?? 500) / 7;
    final bars = <double>[
      baseValue * 0.4,
      baseValue * 0.6,
      baseValue * 1.5,
      baseValue * 0.3,
      baseValue * 0.5,
      baseValue * 0.9,
      baseValue * 0.7,
    ];
    final maxVal = bars.reduce(math.max);
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TENDENCIA SEMANAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
            ),
            child: SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final ratio = maxVal > 0 ? bars[i] / maxVal : 0.0;
                  final isHighest = bars[i] == maxVal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            height: 120 * ratio,
                            decoration: BoxDecoration(
                              color: isHighest ? _kOrange : _kOrange.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Label
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isHighest ? AppColors.textPrimary : AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  String _formatMoney(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$intPart.${parts[1]}';
  }
}

// ─────────────────────────────────────────────────────────────
// METRIC CARD widget
// ─────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final IconData subtitleIcon;
  final IconData trailingIcon;
  final Color trailingIconColor;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.subtitleIcon,
    required this.trailingIcon,
    required this.trailingIconColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(subtitleIcon, size: 14, color: subtitleColor),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Trailing icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: trailingIconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(trailingIcon, color: trailingIconColor, size: 26),
          ),
        ],
      ),
    );
  }
}
