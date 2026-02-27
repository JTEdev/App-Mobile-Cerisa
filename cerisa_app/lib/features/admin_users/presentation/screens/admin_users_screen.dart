import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/features/admin_users/presentation/providers/admin_users_provider.dart';

/// Pantalla de administración de usuarios.
///
/// Permite al administrador:
/// - Ver la lista completa de usuarios registrados.
/// - Cambiar el rol de un usuario (ADMIN ↔ CLIENTE).
/// - Eliminar usuarios del sistema (con confirmación).
///
/// Se conecta al endpoint `/api/users` del backend a través
/// del [AdminUsersProvider].
class AdminUsersScreen extends StatefulWidget {
  /// Constructor constante.
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

/// Estado de [AdminUsersScreen].
///
/// Carga la lista de usuarios al iniciar y proporciona
/// acciones de gestión a través de diálogos interactivos.
class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar la lista de usuarios al abrir la pantalla
    Future.microtask(() {
      context.read<AdminUsersProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          // Botón para recargar la lista manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar lista',
            onPressed: () => context.read<AdminUsersProvider>().loadUsers(),
          ),
        ],
      ),
      body: Consumer<AdminUsersProvider>(
        builder: (context, provider, _) {
          // Estado de carga
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de error
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadUsers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lista vacía
          if (provider.users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }

          // Lista de usuarios
          return RefreshIndicator(
            onRefresh: () => provider.loadUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                final isAdmin = user.rol == 'ADMIN';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    // Ícono con color según el rol
                    leading: CircleAvatar(
                      backgroundColor: isAdmin ? Colors.deepPurple.shade100 : Colors.blue.shade100,
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: isAdmin ? Colors.deepPurple : Colors.blue,
                      ),
                    ),
                    // Nombre del usuario
                    title: Text(user.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    // Email y rol
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        const SizedBox(height: 4),
                        // Chip con el rol actual
                        Chip(
                          label: Text(
                            user.rol,
                            style: TextStyle(
                              fontSize: 11,
                              color: isAdmin ? Colors.deepPurple : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: isAdmin ? Colors.deepPurple.shade50 : Colors.blue.shade50,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    // Menú de acciones
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleAction(value, user),
                      itemBuilder: (context) => [
                        // Opción para cambiar rol
                        PopupMenuItem(
                          value: 'role',
                          child: ListTile(
                            leading: const Icon(Icons.swap_horiz),
                            title: Text(isAdmin ? 'Cambiar a CLIENTE' : 'Cambiar a ADMIN'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        // Separador
                        const PopupMenuDivider(),
                        // Opción para eliminar
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Eliminar usuario', style: TextStyle(color: Colors.red)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Maneja las acciones del menú contextual de cada usuario.
  ///
  /// [action] puede ser 'role' (cambiar rol) o 'delete' (eliminar).
  /// [user] es el modelo del usuario sobre el que se actúa.
  void _handleAction(String action, UserModel user) {
    switch (action) {
      case 'role':
        _showChangeRoleDialog(user);
        break;
      case 'delete':
        _showDeleteDialog(user);
        break;
    }
  }

  /// Muestra un diálogo de confirmación para cambiar el rol del usuario.
  ///
  /// El nuevo rol se determina automáticamente: si es ADMIN pasa a CLIENTE
  /// y viceversa. Al confirmar, llama al provider para ejecutar la operación.
  void _showChangeRoleDialog(UserModel user) {
    final newRole = user.rol == 'ADMIN' ? 'CLIENTE' : 'ADMIN';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar Rol'),
        content: Text('¿Cambiar el rol de "${user.nombre}" de ${user.rol} a $newRole?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<AdminUsersProvider>();
              final success = await provider.updateUserRole(user.id, newRole);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Rol actualizado a $newRole' : 'Error al actualizar el rol'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación para eliminar un usuario.
  ///
  /// Advierte que la operación es irreversible. Al confirmar,
  /// llama al provider para ejecutar la eliminación.
  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de eliminar a "${user.nombre}" (${user.email})?\n\n'
          'Esta acción es irreversible.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<AdminUsersProvider>();
              final success = await provider.deleteUser(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Usuario eliminado correctamente' : 'Error al eliminar el usuario'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
