import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';

/// Pantalla de inicio del panel de administración.
///
/// Muestra un dashboard con métricas de ventas, tendencia semanal,
/// nivel del vendedor y accesos rápidos a la gestión operativa.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName ?? 'Admin';
    // Obtener solo el primer nombre
    final firstName = userName.split(' ').first;

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
                _buildVentasHoyCard(),
                const SizedBox(height: 12),
                _buildTendenciaSemanalCard(),
                const SizedBox(height: 12),
                _buildEstadoActualCard(),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
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
  Widget _buildVentasHoyCard() {
    const double ventas = 1240.00;
    const double meta = 2000.00;
    const double porcentaje = ventas / meta;
    const int porcentajeInt = 70;

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
              const Text(
                '\$1,240.00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const Spacer(),
              // Tendencia +12%
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: AppColors.success, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700),
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
                'META: \$${meta.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success),
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
  Widget _buildTendenciaSemanalCard() {
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
                const Text(
                  '\$8,450.20',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          // Gráfico de barras mini
          _buildMiniBarChart(),
        ],
      ),
    );
  }

  /// Mini gráfico de barras decorativo
  Widget _buildMiniBarChart() {
    final barHeights = [28.0, 40.0, 24.0, 48.0, 36.0, 44.0, 32.0];
    final barColors = [
      const Color(0xFFE8734A),
      AppColors.success,
      const Color(0xFFE8734A),
      AppColors.success,
      const Color(0xFFE8734A),
      AppColors.success,
      const Color(0xFFE8734A),
    ];

    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(barHeights.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 10,
              height: barHeights[i],
              decoration: BoxDecoration(
                color: barColors[i].withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Tarjeta "Estado Actual — Nivel Pro"
  Widget _buildEstadoActualCard() {
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
              color: const Color(0xFF5B8DBE).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star_rounded, color: Color(0xFF5B8DBE), size: 24),
          ),
          const SizedBox(width: 14),
          // Textos: Estado Actual / Nivel Pro
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado Actual',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
                SizedBox(height: 2),
                Text(
                  'Nivel Pro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          // Próximo bono
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'PRÓXIMO BONO',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                '\$500 faltantes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success.withValues(alpha: 0.9),
                ),
              ),
            ],
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
