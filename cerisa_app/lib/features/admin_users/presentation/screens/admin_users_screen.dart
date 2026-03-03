import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/admin_users/presentation/providers/admin_users_provider.dart';

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Tipo de cliente según cantidad de compras simuladas.
enum _ClientTier { vip, frecuente, nuevo }

class _TierInfo {
  final String label;
  final Color bg;
  final Color fg;
  const _TierInfo(this.label, this.bg, this.fg);
}

_ClientTier _tierFor(UserModel user) {
  // Simulación basada en ID par/impar + hash del nombre.
  final hash = user.nombre.length + user.id;
  if (hash % 5 == 0) return _ClientTier.vip;
  if (hash % 3 == 0) return _ClientTier.frecuente;
  return _ClientTier.nuevo;
}

_TierInfo _tierInfoFor(_ClientTier tier) {
  switch (tier) {
    case _ClientTier.vip:
      return const _TierInfo(
        'VIP',
        Color(0xFFE8734A),
        Colors.white,
      );
    case _ClientTier.frecuente:
      return _TierInfo(
        'FRECUENTE',
        Colors.grey.shade300,
        Colors.grey.shade800,
      );
    case _ClientTier.nuevo:
      return _TierInfo(
        'NUEVO',
        const Color(0xFFD5F5E3),
        const Color(0xFF27AE60),
      );
  }
}

int _purchasesFor(UserModel u) {
  final hash = u.nombre.length + u.id;
  if (hash % 5 == 0) return 5 + (hash % 8);
  if (hash % 3 == 0) return 8 + (hash % 10);
  return 1 + (hash % 3);
}

String _locationFor(UserModel u) {
  const locations = [
    'Lima, PE',
    'Cusco, PE',
    'Arequipa, PE',
    'Trujillo, PE',
    'Piura, PE',
  ];
  return locations[u.id % locations.length];
}

// ─────────────────────────────────────────────────────────────
// Avatar colors (deterministic by user id)
// ─────────────────────────────────────────────────────────────

const _avatarColors = [
  Color(0xFF5D3F24),
  Color(0xFFE8734A),
  Color(0xFF3E7CB1),
  Color(0xFF7B5B3A),
  Color(0xFF27AE60),
  Color(0xFF8E44AD),
];

/// Pantalla "Mis Clientes" para el vendedor.
///
/// Muestra solo los usuarios con rol CLIENTE, con tarjetas
/// que incluyen avatar, badge de tier, ubicación, compras,
/// botón de teléfono y "VER DETALLE".
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminUsersProvider>().loadUsers());
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> all) {
    // Solo clientes
    var list = all.where((u) => u.rol == 'CLIENTE').toList();
    if (_query.isNotEmpty) {
      list = list
          .where((u) => u.nombre.toLowerCase().contains(_query))
          .toList();
    }
    // Alfabético
    list.sort((a, b) => a.nombre.compareTo(b.nombre));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: Consumer<AdminUsersProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.users.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8734A),
                      ),
                    );
                  }
                  if (provider.error != null && provider.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(provider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => provider.loadUsers(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final clients = _filtered(provider.users);

                  if (clients.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay clientes registrados',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFE8734A),
                    onRefresh: () => provider.loadUsers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: clients.length,
                      itemBuilder: (_, i) => _buildClientCard(clients[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          // Botón regresar
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Mis Clientes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Botón agregar cliente
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8734A).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: Color(0xFFE8734A),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.35)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar cliente por nombre...',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _searchCtrl.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CLIENT CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildClientCard(UserModel user) {
    final tier = _tierFor(user);
    final info = _tierInfoFor(tier);
    final purchases = _purchasesFor(user);
    final location = _locationFor(user);
    final avatarColor = _avatarColors[user.id % _avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Row: Avatar + Info + Phone
          Row(
            children: [
              // Avatar circular con iniciales
              CircleAvatar(
                radius: 30,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  _initials(user.nombre),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: avatarColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Nombre, badge, location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge tier
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: info.bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            info.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: info.fg,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.6)),
                        const SizedBox(width: 3),
                        Text(
                          '$location • $purchases compra${purchases > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Phone button
              GestureDetector(
                onTap: () {
                  // Placeholder: en el futuro abriría tel:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        user.telefono != null
                            ? 'Llamar a ${user.telefono}'
                            : 'Sin teléfono registrado',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF27AE60),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Botón VER DETALLE
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _showClientDetail(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8734A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'VER DETALLE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ─────────────────────────────────────────────────────────────
  // CLIENT DETAIL BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────

  void _showClientDetail(UserModel user) {
    final tier = _tierFor(user);
    final info = _tierInfoFor(tier);
    final purchases = _purchasesFor(user);
    final location = _locationFor(user);
    final avatarColor = _avatarColors[user.id % _avatarColors.length];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Avatar grande
              CircleAvatar(
                radius: 40,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  _initials(user.nombre),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: avatarColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Nombre + badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: info.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      info.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: info.fg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              // Info cards row
              Row(
                children: [
                  _detailInfoCard(
                    Icons.location_on_outlined,
                    'Ubicación',
                    location,
                  ),
                  const SizedBox(width: 12),
                  _detailInfoCard(
                    Icons.shopping_bag_outlined,
                    'Compras',
                    '$purchases',
                  ),
                  const SizedBox(width: 12),
                  _detailInfoCard(
                    Icons.phone_outlined,
                    'Teléfono',
                    user.telefono ?? 'N/A',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Fecha de registro
              if (user.creadoEn != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        'Cliente desde: ${_formatDate(user.creadoEn!)}',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Botón llamar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          user.telefono != null
                              ? 'Llamando a ${user.telefono}...'
                              : 'Sin teléfono registrado',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text(
                    'Contactar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFE8734A)),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
