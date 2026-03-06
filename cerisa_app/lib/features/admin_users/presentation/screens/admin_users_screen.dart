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
      return const _TierInfo('VIP', Color(0xFFE8734A), Colors.white);
    case _ClientTier.frecuente:
      return _TierInfo('FRECUENTE', Colors.grey.shade300, Colors.grey.shade800);
    case _ClientTier.nuevo:
      return _TierInfo('NUEVO', const Color(0xFFD5F5E3), const Color(0xFF27AE60));
  }
}

int _purchasesFor(UserModel u) {
  final hash = u.nombre.length + u.id;
  if (hash % 5 == 0) return 5 + (hash % 8);
  if (hash % 3 == 0) return 8 + (hash % 10);
  return 1 + (hash % 3);
}

String _locationFor(UserModel u) {
  const locations = ['Lima, PE', 'Cusco, PE', 'Arequipa, PE', 'Trujillo, PE', 'Piura, PE'];
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
      list = list.where((u) => u.nombre.toLowerCase().contains(_query)).toList();
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
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE8734A)));
                  }
                  if (provider.error != null && provider.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 12),
                          TextButton(onPressed: () => provider.loadUsers(), child: const Text('Reintentar')),
                        ],
                      ),
                    );
                  }

                  final clients = _filtered(provider.users);

                  if (clients.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay clientes registrados',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
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
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          const Text(
            'Mis Clientes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const Spacer(),
          // Botón agregar cliente
          GestureDetector(
            onTap: () => _showClientForm(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: const Color(0xFFE8734A).withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.person_add_outlined, color: Color(0xFFE8734A), size: 22),
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
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 20),
            suffixIcon: _query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchCtrl.clear())
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: avatarColor),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: info.bg, borderRadius: BorderRadius.circular(8)),
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
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$location • $purchases compra${purchases > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.7)),
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
                      content: Text(user.telefono != null ? 'Llamar a ${user.telefono}' : 'Sin teléfono registrado'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: const Icon(Icons.phone, color: Color(0xFF27AE60), size: 22),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('VER DETALLE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
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
  // ADD / EDIT CLIENT FORM
  // ─────────────────────────────────────────────────────────────

  void _showClientForm({UserModel? user}) {
    final isEditing = user != null;
    final nombreCtrl = TextEditingController(text: user?.nombre ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final telefonoCtrl = TextEditingController(text: user?.telefono ?? '');
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(height: 20),
                        // Título
                        Text(
                          isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Nombre
                        _formField(
                          controller: nombreCtrl,
                          label: 'Nombre completo',
                          icon: Icons.person_outlined,
                          validator: (v) => (v == null || v.trim().length < 2) ? 'Mínimo 2 caracteres' : null,
                        ),
                        const SizedBox(height: 14),
                        // Email
                        _formField(
                          controller: emailCtrl,
                          label: 'Correo electrónico',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El email es obligatorio';
                            if (!v.contains('@') || !v.contains('.')) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        // Teléfono
                        _formField(
                          controller: telefonoCtrl,
                          label: 'Número de celular',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        // Contraseña (solo para nuevo)
                        if (!isEditing)
                          _formField(
                            controller: passwordCtrl,
                            label: 'Contraseña (opcional)',
                            icon: Icons.lock_outlined,
                            obscure: true,
                            hint: 'Se usará Cerisa2026 por defecto',
                          ),
                        if (!isEditing) const SizedBox(height: 14),
                        const SizedBox(height: 10),
                        // Botón guardar
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    setSheetState(() => saving = true);

                                    final provider = context.read<AdminUsersProvider>();
                                    final data = <String, dynamic>{
                                      'nombre': nombreCtrl.text.trim(),
                                      'email': emailCtrl.text.trim(),
                                    };
                                    final tel = telefonoCtrl.text.trim();
                                    if (tel.isNotEmpty) data['telefono'] = tel;
                                    if (!isEditing && passwordCtrl.text.isNotEmpty) {
                                      data['password'] = passwordCtrl.text;
                                    }

                                    bool ok;
                                    if (isEditing) {
                                      ok = await provider.updateClient(user.id, data);
                                    } else {
                                      ok = await provider.createClient(data);
                                    }

                                    setSheetState(() => saving = false);

                                    if (!ctx.mounted) return;
                                    if (ok) {
                                      Navigator.pop(ctx);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEditing ? 'Cliente actualizado' : 'Cliente creado exitosamente',
                                            ),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(provider.error ?? 'Error desconocido'),
                                          backgroundColor: AppColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8734A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    isEditing ? 'ACTUALIZAR CLIENTE' : 'CREAR CLIENTE',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscure = false,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.4)),
        labelStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFFE8734A).withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8734A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
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
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              // Avatar grande
              CircleAvatar(
                radius: 40,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  _initials(user.nombre),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: avatarColor),
                ),
              ),
              const SizedBox(height: 14),
              // Nombre + badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.nombre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: info.bg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      info.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: info.fg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(user.email, style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.7))),
              const SizedBox(height: 24),
              // Info cards row
              Row(
                children: [
                  _detailInfoCard(Icons.location_on_outlined, 'Ubicación', location),
                  const SizedBox(width: 12),
                  _detailInfoCard(Icons.shopping_bag_outlined, 'Compras', '$purchases'),
                  const SizedBox(width: 12),
                  _detailInfoCard(Icons.phone_outlined, 'Teléfono', user.telefono ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 20),
              // Fecha de registro
              if (user.creadoEn != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cliente desde: ${_formatDate(user.creadoEn!)}',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Botones: Editar + Contactar
              Row(
                children: [
                  // Botón editar
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showClientForm(user: user);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: const Text('Editar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE8734A),
                          side: const BorderSide(color: Color(0xFFE8734A), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón contactar
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                user.telefono != null ? 'Llamando a ${user.telefono}...' : 'Sin teléfono registrado',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text('Contactar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Botón eliminar
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmDelete(user);
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Eliminar cliente', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar cliente', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar a "${user.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await context.read<AdminUsersProvider>().deleteUser(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Cliente eliminado' : 'Error al eliminar'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _detailInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFE8734A)),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
