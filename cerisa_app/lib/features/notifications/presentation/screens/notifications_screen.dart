import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:cerisa_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:cerisa_app/features/admin_products/presentation/providers/admin_products_provider.dart';
import 'package:cerisa_app/features/home/presentation/screens/home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationsProvider>().loadNotifications(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<NotificationsProvider>(
          builder: (context, provider, _) {
            final items = provider.notifications;
            final readCount = items.where((n) => n.leida).length;
            final unreadCount = items.where((n) => !n.leida).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(readCount, unreadCount, provider),
                const Divider(height: 1, color: AppColors.divider),
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 20, 22, 12),
                  child: Text(
                    'Actividad Reciente',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : provider.error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(provider.error!, style: const TextStyle(color: AppColors.textSecondary)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => provider.loadNotifications(force: true),
                                    child: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            )
                          : items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Sin notificaciones',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () => provider.loadNotifications(force: true),
                                  color: AppColors.primary,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                                    itemCount: items.length,
                                    itemBuilder: (_, i) => _buildNotifCard(items[i], provider),
                                  ),
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int readCount, int unreadCount, NotificationsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          const Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: unreadCount > 0 ? () => provider.markAllRead() : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: unreadCount > 0
                    ? const Color(0xFFE8734A).withValues(alpha: 0.1)
                    : AppColors.divider.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LE\u00cdDO ($readCount)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: unreadCount > 0
                      ? const Color(0xFFE8734A)
                      : AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(NotificationModel item, NotificationsProvider provider) {
    final config = _configFor(item.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: config.accentColor, width: 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: config.iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(config.icon, color: config.accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.cuerpo,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(item.creadoEn),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    if (!item.leida) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: config.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.markRead(item.id);
                        _handlePrimaryAction(item, provider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        config.primaryLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {
                        provider.markRead(item.id);
                        _handleSecondaryAction(item, provider);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.divider.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        config.secondaryLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _NotifConfig _configFor(String tipo) {
    switch (tipo) {
      case 'PEDIDO':
        return _NotifConfig(
          icon: Icons.shopping_bag_rounded,
          iconBg: const Color(0xFF5D3F24).withValues(alpha: 0.12),
          accentColor: const Color(0xFF5D3F24),
          primaryLabel: 'VER PEDIDO',
          secondaryLabel: 'PREPARAR',
        );
      case 'STOCK_CRITICO':
        return _NotifConfig(
          icon: Icons.warning_amber_rounded,
          iconBg: AppColors.error.withValues(alpha: 0.1),
          accentColor: AppColors.error,
          primaryLabel: 'AJUSTAR STOCK',
          secondaryLabel: 'OCULTAR PRODUCTO',
        );
      case 'CLIENTE':
        return _NotifConfig(
          icon: Icons.person_add_alt_1_rounded,
          iconBg: const Color(0xFF27AE60).withValues(alpha: 0.1),
          accentColor: const Color(0xFF27AE60),
          primaryLabel: 'VER CLIENTE',
          secondaryLabel: 'ENVIAR MENSAJE',
        );
      case 'PAGO':
        return _NotifConfig(
          icon: Icons.payments_rounded,
          iconBg: const Color(0xFFE8734A).withValues(alpha: 0.1),
          accentColor: const Color(0xFFE8734A),
          primaryLabel: 'VER PAGO',
          secondaryLabel: 'DETALLES',
        );
      default:
        return _NotifConfig(
          icon: Icons.notifications_rounded,
          iconBg: AppColors.primary.withValues(alpha: 0.1),
          accentColor: AppColors.primary,
          primaryLabel: 'VER',
          secondaryLabel: 'DESCARTAR',
        );
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) {
        final h = dt.hour;
        final m = dt.minute.toString().padLeft(2, '0');
        final period = h >= 12 ? 'PM' : 'AM';
        final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return '$h12:$m $period';
      }
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} d\u00edas';

      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }

  void _goToHomeTab(int tabIndex) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == '/home' || route.isFirst,
    );
    HomeScreen.switchToTab(tabIndex);
  }

  void _handlePrimaryAction(NotificationModel item, NotificationsProvider provider) {
    switch (item.tipo) {
      case 'PEDIDO':
      case 'PAGO':
        _goToHomeTab(2); // PEDIDOS tab
        break;
      case 'STOCK_CRITICO':
        Navigator.pushNamed(context, AppRoutes.adminStock);
        break;
      case 'CLIENTE':
        _goToHomeTab(3); // CLIENTES tab
        break;
      default:
        _showSnack('Notificaci\u00f3n: ${item.titulo}');
    }
  }

  void _handleSecondaryAction(NotificationModel item, NotificationsProvider provider) async {
    switch (item.tipo) {
      case 'PEDIDO':
        if (item.referenciaId != null) {
          final ordersProvider = context.read<OrdersProvider>();
          final ok = await ordersProvider.updateStatus(item.referenciaId!, 'EN_PREPARACION');
          if (mounted) {
            _showSnack(ok
                ? 'Pedido #${item.referenciaId} en preparaci\u00f3n'
                : 'Error al actualizar pedido');
          }
        }
        break;
      case 'STOCK_CRITICO':
        if (item.referenciaId != null) {
          final productsProvider = context.read<AdminProductsProvider>();
          final ok = await productsProvider.updateProduct(
              item.referenciaId!, {'activo': false});
          if (mounted) {
            _showSnack(ok
                ? 'Producto ocultado del cat\u00e1logo'
                : 'Error al ocultar producto');
          }
        }
        break;
      case 'CLIENTE':
        _showSnack('Funci\u00f3n de mensajer\u00eda pr\u00f3ximamente');
        break;
      case 'PAGO':
        _goToHomeTab(2); // PEDIDOS tab
        break;
      default:
        break;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _NotifConfig {
  final IconData icon;
  final Color iconBg;
  final Color accentColor;
  final String primaryLabel;
  final String secondaryLabel;
  const _NotifConfig({
    required this.icon,
    required this.iconBg,
    required this.accentColor,
    required this.primaryLabel,
    required this.secondaryLabel,
  });
}