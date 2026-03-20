import 'package:flutter/material.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/home/presentation/screens/home_screen.dart';

/// Bottom navigation bar for standalone admin screens (Stock, Products, Reports).
/// Tapping any item pops back to HomeScreen and switches to the corresponding tab.
class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, 0, Icons.grid_view_outlined, 'INICIO'),
              _buildItem(context, 1, Icons.storefront_outlined, 'CAT\u00c1LOGO'),
              _buildItem(context, 2, Icons.receipt_long_outlined, 'PEDIDOS'),
              _buildItem(context, 3, Icons.people_outline, 'CLIENTES'),
              _buildItem(context, 4, Icons.person_outline, 'PERFIL'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int tabIndex, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == '/home' || route.isFirst,
        );
        HomeScreen.switchToTab(tabIndex);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
