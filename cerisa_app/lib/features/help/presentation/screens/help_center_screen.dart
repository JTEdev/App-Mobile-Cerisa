import 'package:flutter/material.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _expandedFaqIndex;

  final List<_HelpCategory> _categories = [
    _HelpCategory(
      icon: Icons.inventory_2_rounded,
      title: 'Mis Pedidos',
      description: 'Estado, seguimiento y problemas con pedidos',
    ),
    _HelpCategory(
      icon: Icons.local_shipping_rounded,
      title: 'Env\u00edos y Entregas',
      description: 'Tiempos de env\u00edo, cobertura y rastreo',
    ),
    _HelpCategory(
      icon: Icons.refresh_rounded,
      title: 'Devoluciones',
      description: 'Pol\u00edticas de cambio y devoluci\u00f3n',
    ),
    _HelpCategory(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Pagos y Facturaci\u00f3n',
      description: 'M\u00e9todos de pago, facturas y reembolsos',
    ),
  ];

  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: '\u00bfC\u00f3mo cuidar mis piezas?',
      answer:
          'Nuestras piezas artesanales requieren cuidados especiales. '
          'Evita el contacto con agua, perfumes y productos qu\u00edmicos. '
          'Gu\u00e1rdalas en un lugar seco y separadas entre s\u00ed para evitar rayones. '
          'Limpia con un pa\u00f1o suave y seco despu\u00e9s de cada uso.',
    ),
    _FaqItem(
      question: '\u00bfCu\u00e1l es el tiempo de entrega?',
      answer:
          'El tiempo de entrega var\u00eda seg\u00fan tu ubicaci\u00f3n:\n'
          '\u2022 Lima Metropolitana: 2-3 d\u00edas h\u00e1biles\n'
          '\u2022 Provincias: 5-7 d\u00edas h\u00e1biles\n'
          '\u2022 Pedidos personalizados: 10-15 d\u00edas h\u00e1biles\n\n'
          'Recibir\u00e1s notificaciones con el estado de tu env\u00edo.',
    ),
    _FaqItem(
      question: '\u00bfHacen pedidos personalizados?',
      answer:
          '\u00a1S\u00ed! Realizamos piezas personalizadas bajo pedido. '
          'Puedes contactarnos por WhatsApp o a trav\u00e9s de la secci\u00f3n de contacto '
          'para solicitar un dise\u00f1o especial. El tiempo de elaboraci\u00f3n depende '
          'de la complejidad de la pieza.',
    ),
    _FaqItem(
      question: '\u00bfCu\u00e1l es la pol\u00edtica de devoluci\u00f3n?',
      answer:
          'Aceptamos devoluciones dentro de los 7 d\u00edas posteriores a la entrega, '
          'siempre que el producto est\u00e9 en su estado original y con empaque. '
          'Los pedidos personalizados no aplican para devoluci\u00f3n. '
          'Contacta a nuestro equipo para iniciar el proceso.',
    ),
    _FaqItem(
      question: '\u00bfQu\u00e9 m\u00e9todos de pago aceptan?',
      answer:
          'Aceptamos los siguientes m\u00e9todos de pago:\n'
          '\u2022 Tarjetas de cr\u00e9dito y d\u00e9bito (Visa, Mastercard)\n'
          '\u2022 Transferencia bancaria\n'
          '\u2022 Yape y Plin\n'
          '\u2022 Pago contra entrega (solo Lima)',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            // Accent line
            Container(height: 2, color: AppColors.accent),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                children: [
                  // Heading
                  const Text(
                    '\u00bfEn qu\u00e9 podemos\nayudarte hoy?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search bar
                  _buildSearchBar(),
                  const SizedBox(height: 28),
                  // Category cards
                  ..._categories.map(_buildCategoryCard),
                  const SizedBox(height: 32),
                  // FAQ section
                  const Text(
                    'Preguntas Frecuentes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  ..._faqs.asMap().entries.map((entry) => _buildFaqItem(entry.key, entry.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Centro de Ayuda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 48), // balance the back button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar ayuda, pedidos...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(_HelpCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () {
            // Category tap action
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, size: 22, color: AppColors.accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.divider, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, _FaqItem faq) {
    final isExpanded = _expandedFaqIndex == index;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedFaqIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? AppColors.accent : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Answer
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(faq.answer, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.4)),
      ],
    );
  }
}

class _HelpCategory {
  final IconData icon;
  final String title;
  final String description;

  const _HelpCategory({required this.icon, required this.title, required this.description});
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
