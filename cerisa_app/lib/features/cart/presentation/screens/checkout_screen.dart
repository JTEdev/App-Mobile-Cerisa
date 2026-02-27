import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:cerisa_app/features/orders/presentation/screens/order_success_screen.dart';

/// Pantalla de checkout estilo e-commerce profesional.
///
/// Diseño con:
/// - Stepper visual (Envío ✓ → Pago 2 → Confirmar 3)
/// - Dirección de envío con opción "Cambiar"
/// - Método de envío (Estándar / Express) con radio buttons
/// - Método de pago con tarjeta por defecto
/// - Resumen del pedido (Subtotal, Envío, Impuesto, Total)
/// - Botón "Realizar Pedido ✓"
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _direccionController = TextEditingController(text: 'Jr. Las Cerámicas 1234, Apt 4B');
  final _ciudadController = TextEditingController(text: 'Lima, Lima 15001');
  final _paisController = TextEditingController(text: 'Perú');
  final _notasController = TextEditingController();

  String _shippingMethod = 'standard'; // 'standard' o 'express'
  bool _isEditingAddress = false;

  double get _shippingCost => _shippingMethod == 'standard' ? 12.00 : 24.00;
  String get _shippingLabel => _shippingMethod == 'standard' ? 'Estándar' : 'Express';

  @override
  void dispose() {
    _direccionController.dispose();
    _ciudadController.dispose();
    _paisController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    // Capturar datos antes de que checkout limpie el carrito
    final subtotal = cart.total;
    final tax = subtotal * 0.10;
    final grandTotal = subtotal + _shippingCost + tax;
    final itemCount = cart.itemCount;
    final userName = auth.userName ?? 'Cliente';

    final fullAddress = '${_direccionController.text}, ${_ciudadController.text}, ${_paisController.text}';
    final success = await cart.checkout(direccion: fullAddress, notas: _notasController.text);

    if (!mounted) return;

    if (success) {
      // Navegar a pantalla de éxito
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderSuccess,
        (route) => false,
        arguments: OrderSuccessArgs(
          total: grandTotal,
          itemCount: itemCount,
          shippingMethod: _shippingMethod,
          userName: userName,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.error ?? 'Error al procesar el pedido'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, _) {
            final subtotal = cart.total;
            final tax = subtotal * 0.10;
            final grandTotal = subtotal + _shippingCost + tax;

            return Column(
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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    children: [
                      // Stepper visual
                      _buildStepper(),
                      const SizedBox(height: 24),

                      // Dirección de envío
                      _buildShippingAddress(),
                      const SizedBox(height: 24),

                      // Método de envío
                      _buildShippingMethod(),
                      const SizedBox(height: 24),

                      // Método de pago
                      _buildPaymentMethod(),
                      const SizedBox(height: 24),

                      // Notas adicionales
                      _buildNotesField(),
                      const SizedBox(height: 24),

                      // Resumen del pedido
                      _buildOrderSummary(cart, subtotal, tax, grandTotal),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Botón "Realizar Pedido" fijo abajo ──
                _buildPlaceOrderButton(cart),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Barra superior: ← + "Checkout"
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Checkout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.accent, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  /// Stepper visual: Envío ✓ → Pago 2 → Confirmar 3
  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepCircle(icon: Icons.check_rounded, isCompleted: true),
        _buildStepLine(isActive: true),
        _buildStepCircle(label: '2', isActive: true),
        _buildStepLine(isActive: false),
        _buildStepCircle(label: '3', isActive: false),
      ],
    );
  }

  Widget _buildStepCircle({String? label, IconData? icon, bool isCompleted = false, bool isActive = false}) {
    final isHighlighted = isCompleted || isActive;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.accent : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: isHighlighted ? AppColors.accent : AppColors.divider, width: 2),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 18, color: Colors.white)
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isHighlighted ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isCompleted ? 'Envío' : (label == '2' ? 'Pago' : 'Confirmar'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Container(height: 2.5, color: isActive ? AppColors.accent : AppColors.divider.withValues(alpha: 0.5)),
      ),
    );
  }

  /// Dirección de envío.
  Widget _buildShippingAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dirección de Envío',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () => setState(() => _isEditingAddress = !_isEditingAddress),
              child: Text(
                _isEditingAddress ? 'Listo' : 'Cambiar',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: _isEditingAddress
              ? _buildAddressForm()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 20, color: AppColors.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Casa',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _direccionController.text,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                          Text(
                            _ciudadController.text,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            _paisController.text,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Formulario editable de dirección.
  Widget _buildAddressForm() {
    return Column(
      children: [
        _buildFormField(_direccionController, 'Dirección', Icons.home_rounded),
        const SizedBox(height: 10),
        _buildFormField(_ciudadController, 'Ciudad', Icons.location_city_rounded),
        const SizedBox(height: 10),
        _buildFormField(_paisController, 'País', Icons.public_rounded),
      ],
    );
  }

  Widget _buildFormField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  /// Método de envío con selección radio.
  Widget _buildShippingMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de Envío',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        // Estándar
        _buildShippingOption(
          value: 'standard',
          title: 'Envío Estándar',
          subtitle: '3-5 días hábiles',
          price: 'S/ 12.00',
        ),
        const SizedBox(height: 10),
        // Express
        _buildShippingOption(value: 'express', title: 'Envío Express', subtitle: '1-2 días hábiles', price: 'S/ 24.00'),
      ],
    );
  }

  Widget _buildShippingOption({
    required String value,
    required String title,
    required String subtitle,
    required String price,
  }) {
    final isSelected = _shippingMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _shippingMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider.withValues(alpha: 0.5),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.accent : AppColors.divider, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            // Precio
            Text(
              price,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }

  /// Método de pago.
  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {
                // TODO: cambiar método de pago
              },
              child: const Text(
                'Cambiar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              // Ícono de tarjeta
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.credit_card_rounded, size: 22, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              // Info de la tarjeta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Mastercard',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.divider.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text('**** **** **** 4242', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              // Radio seleccionado
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Campo de notas opcionales.
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas (opcional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notasController,
          maxLines: 2,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Instrucciones especiales de entrega...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.note_rounded, size: 20, color: AppColors.accent),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  /// Resumen del pedido.
  Widget _buildOrderSummary(CartProvider cart, double subtotal, double tax, double grandTotal) {
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
            'Resumen del Pedido',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal (${cart.itemCount} items)', 'S/ ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildSummaryRow('Envío ($_shippingLabel)', 'S/ ${_shippingCost.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildSummaryRow('Impuesto', 'S/ ${tax.toStringAsFixed(2)}'),
          const SizedBox(height: 14),
          Divider(color: AppColors.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                'S/ ${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  /// Botón "Realizar Pedido" fijo en la parte inferior.
  Widget _buildPlaceOrderButton(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: cart.isLoading ? null : _handleCheckout,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: cart.isLoading ? AppColors.accent.withValues(alpha: 0.6) : AppColors.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: cart.isLoading
                ? const Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Realizar Pedido',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
