import 'package:flutter/material.dart';

/// Widget reutilizable que muestra un indicador de carga circular centrado.
///
/// Se usa en pantallas mientras se cargan datos desde el API.
class AppLoadingIndicator extends StatelessWidget {
  /// Constructor constante.
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Widget reutilizable para mostrar un estado de error con opción de reintento.
///
/// Muestra un ícono de error, el [message] descriptivo y opcionalmente
/// un botón "Reintentar" si se proporciona [onRetry].
class AppErrorWidget extends StatelessWidget {
  /// Mensaje de error a mostrar al usuario.
  final String message;

  /// Callback opcional que se ejecuta al presionar "Reintentar".
  final VoidCallback? onRetry;

  /// Constructor del widget de error.
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }
}

/// Widget reutilizable para mostrar un estado vacío (sin datos).
///
/// Muestra un ícono grande y un [message] explicativo.
/// Se usa cuando una lista o consulta no devuelve resultados.
class AppEmptyWidget extends StatelessWidget {
  /// Mensaje que describe el estado vacío.
  final String message;

  /// Ícono a mostrar (por defecto: bandeja vacía).
  final IconData icon;

  /// Constructor del widget de estado vacío.
  const AppEmptyWidget({super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
