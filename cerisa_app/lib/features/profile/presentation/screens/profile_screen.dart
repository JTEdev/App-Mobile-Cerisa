import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/auth/presentation/providers/auth_provider.dart';

/// Pantalla de perfil del usuario estilo e-commerce.
///
/// Diseño profesional con avatar circular, nombre, email,
/// tarjeta de opciones con íconos circulares, y botón de cerrar sesión.
/// Si el usuario es admin, muestra opciones de administración adicionales.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior ──
            _buildTopBar(context),
            // ── Contenido scrollable ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  const SizedBox(height: 16),
                  // Avatar + Nombre + Email
                  _buildProfileHeader(context, auth),
                  const SizedBox(height: 32),
                  // Opciones del cliente
                  _buildOptionsCard(context, auth),
                  // Opciones de administración (solo admin)
                  if (auth.isAdmin) ...[const SizedBox(height: 20), _buildAdminSection(context)],
                  const SizedBox(height: 32),
                  // Botón cerrar sesión
                  _buildLogoutButton(context, auth),
                  const SizedBox(height: 16),
                  // Versión de la app
                  const Center(
                    child: Text('App Versión 1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barra superior con flecha de retorno, título y engranaje.
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          const Expanded(
            child: Text(
              'Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary, size: 22),
              onPressed: () {
                // TODO: pantalla de configuración
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar circular con borde gradiente, botón de editar, nombre y email.
  Widget _buildProfileHeader(BuildContext context, AuthProvider auth) {
    final initial = (auth.userName ?? 'U')[0].toUpperCase();

    return Center(
      child: Column(
        children: [
          // Avatar con borde degradado y botón editar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.accent.withValues(alpha: 0.4), AppColors.divider.withValues(alpha: 0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ),
              // Botón de editar
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                  boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nombre
          Text(
            auth.userName ?? 'Usuario',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          // Email
          Text(auth.userEmail ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          // Badge de rol
          if (auth.isAdmin) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Administrador',
                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Tarjeta con las opciones de navegación del usuario.
  Widget _buildOptionsCard(BuildContext context, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildOptionItem(
            icon: Icons.inventory_2_rounded,
            title: 'Mis Pedidos',
            onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.location_on_rounded,
            title: 'Direcciones',
            onTap: () {
              // TODO: pantalla de direcciones
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.credit_card_rounded,
            title: 'Métodos de Pago',
            onTap: () {
              // TODO: pantalla de métodos de pago
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.notifications_rounded,
            title: 'Notificaciones',
            onTap: () {
              // TODO: pantalla de notificaciones
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            icon: Icons.help_outline_rounded,
            title: 'Centro de Ayuda',
            onTap: () {
              // TODO: pantalla de ayuda
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Sección de administración.
  Widget _buildAdminSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Administración',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildOptionItem(
                icon: Icons.inventory_rounded,
                title: 'Gestión Productos',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminProducts),
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.warehouse_rounded,
                title: 'Gestión Stock',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminStock),
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.list_alt_rounded,
                title: 'Gestión Pedidos',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrders),
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.bar_chart_rounded,
                title: 'Reportes',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminReports),
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.people_rounded,
                title: 'Usuarios',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Ítem de opción individual dentro de la tarjeta.
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(20)) : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // Ícono circular con fondo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              // Título
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              // Chevron
              const Icon(Icons.chevron_right_rounded, color: AppColors.divider, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// Separador dentro de la tarjeta de opciones.
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.4)),
    );
  }

  /// Botón de cerrar sesión.
  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            content: const Text(
              '¿Estás seguro de que deseas cerrar sesión?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await auth.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.divider.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: AppColors.textSecondary),
            SizedBox(width: 10),
            Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
