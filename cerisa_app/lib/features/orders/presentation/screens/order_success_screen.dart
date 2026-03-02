import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';

/// Argumentos para la pantalla de éxito del pedido.
class OrderSuccessArgs {
  /// Total del pedido (incluye envío e impuesto).
  final double total;

  /// Cantidad de ítems en el pedido.
  final int itemCount;

  /// Método de envío seleccionado ('standard' o 'express').
  final String shippingMethod;

  /// Nombre del usuario.
  final String userName;

  const OrderSuccessArgs({
    required this.total,
    required this.itemCount,
    required this.shippingMethod,
    required this.userName,
  });
}

/// Pantalla de confirmación de pedido exitoso.
///
/// Diseño inspirado en e-commerce artesanal con:
/// - Ilustración decorativa con ícono de check
/// - Confetti animado de fondo
/// - Título "¡Pedido Exitoso!" en accent
/// - Mensaje personalizado con nombre del usuario
/// - Tarjeta con ID de pedido, fecha estimada, total
/// - Botón "Seguimiento de Pedido" y "Seguir Comprando"
class OrderSuccessScreen extends StatefulWidget {
  final OrderSuccessArgs args;

  const OrderSuccessScreen({super.key, required this.args});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  late final String _orderId;
  late final DateTime _estimatedDelivery;

  @override
  void initState() {
    super.initState();

    // Generar ID de pedido estilo Cerisa
    final random = Random();
    _orderId = 'CR-${(random.nextInt(9000) + 1000)}';

    // Fecha estimada según método de envío
    final daysToAdd = widget.args.shippingMethod == 'express' ? 2 : 5;
    _estimatedDelivery = DateTime.now().add(Duration(days: daysToAdd));

    // Animación de entrada
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // ── Contenido central scrollable ──
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // ── Ilustración con confetti ──
                        _buildIllustration(),
                        const SizedBox(height: 28),

                        // ── Título ──
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: const Text(
                            '¡Pedido Exitoso!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accent,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Subtítulo personalizado ──
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Text(
                            '¡Gracias por tu compra, ${widget.args.userName}!\nTu pieza artesanal está siendo preparada.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Tarjeta de detalles ──
                        _buildDetailsCard(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // ── Botones inferiores ──
                _buildBottomActions(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ilustración central: maceta con check y confetti decorativo.
  Widget _buildIllustration() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        height: 220,
        width: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de fondo grande
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.08), shape: BoxShape.circle),
            ),

            // Ícono principal (maceta/cerámica)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.local_florist_rounded, size: 56, color: Colors.white),
            ),

            // Badge de check
            Positioned(
              bottom: 30,
              right: 38,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),

            // ── Confetti decorativo ──
            // Punto superior izquierdo
            Positioned(
              top: 12,
              left: 10,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 10,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            // Punto derecho
            Positioned(
              top: 50,
              right: 15,
              child: Container(
                width: 8,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Círculo inferior izquierdo
            Positioned(
              bottom: 25,
              left: 20,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Punto inferior derecho
            Positioned(
              bottom: 60,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.5), shape: BoxShape.circle),
              ),
            ),
            // Punto medio izquierdo
            Positioned(
              top: 70,
              left: 5,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.4), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta con detalles del pedido.
  Widget _buildDetailsCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            // Order ID
            _buildDetailRow(label: 'ID Pedido', value: '#$_orderId', valueBold: true),
            _buildDivider(),

            // Fecha estimada
            _buildDetailRow(
              label: 'Entrega Estimada',
              value: _formatDate(_estimatedDelivery),
              icon: Icons.calendar_today_rounded,
            ),
            _buildDivider(),

            // Total
            _buildDetailRow(
              label: 'Monto Total',
              value: 'S/ ${widget.args.total.toStringAsFixed(2)}',
              valueColor: AppColors.accent,
              valueBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: AppColors.accent), const SizedBox(width: 6)],
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.divider.withValues(alpha: 0.4), height: 1);
  }

  /// Botones de acción: "Seguimiento de Pedido" + "Seguir Comprando".
  Widget _buildBottomActions() {
    return Column(
      children: [
        // Botón principal: Seguimiento de Pedido
        GestureDetector(
          onTap: () {
            // Capturar el navigator antes de destruir el contexto
            final nav = Navigator.of(context);
            nav.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            // Esperar un frame para que HomeScreen termine de construirse
            WidgetsBinding.instance.addPostFrameCallback((_) {
              nav.pushNamed(AppRoutes.orders);
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Seguimiento de Pedido',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Link secundario: Seguir Comprando
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          },
          child: const Text(
            'Seguir Comprando',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
