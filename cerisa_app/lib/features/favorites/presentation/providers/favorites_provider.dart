import 'package:flutter/material.dart';
import 'package:cerisa_app/core/services/api_service.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';

/// Provider para la gestión de productos favoritos del usuario.
///
/// Permite cargar, agregar y quitar productos de la lista de favoritos.
/// Se comunica con los endpoints `/api/favorites` del backend.
/// Almacena localmente los IDs de favoritos para verificación rápida
/// sin necesidad de consultar al backend en cada pantalla.
class FavoritesProvider extends ChangeNotifier {
  /// Servicio HTTP para comunicarse con el API.
  final ApiService _api;

  /// Lista de productos favoritos cargados desde el backend.
  List<ProductModel> _favorites = [];

  /// Set de IDs de productos favoritos para verificación rápida O(1).
  final Set<int> _favoriteIds = {};

  /// Indica si se está realizando una operación de carga.
  bool _isLoading = false;

  /// Mensaje de error de la última operación fallida.
  String? _error;

  /// Indica si ya se cargaron los favoritos al menos una vez.
  bool _isLoaded = false;

  /// Crea una instancia de [FavoritesProvider] con el [ApiService] proporcionado.
  FavoritesProvider(this._api);

  /// Lista de productos favoritos.
  List<ProductModel> get favorites => _favorites;

  /// Estado de carga actual.
  bool get isLoading => _isLoading;

  /// Mensaje de error actual.
  String? get error => _error;

  /// Verifica si un producto está en la lista de favoritos.
  ///
  /// Usa el Set local [_favoriteIds] para búsqueda O(1).
  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  /// Carga la lista de productos favoritos del usuario autenticado.
  ///
  /// Llama a GET /api/favorites con autenticación JWT.
  /// Actualiza [favorites], [_favoriteIds], [isLoading] y [error].
  /// Si [force] es false y ya se cargaron antes, no hace nada.
  Future<void> loadFavorites({bool force = false}) async {
    if (_isLoading) return;
    if (_isLoaded && !force && _error == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _api.getList('/favorites', auth: true);
      _favorites = list.map((json) => ProductModel.fromJson(json)).toList();
      _favoriteIds.clear();
      for (final p in _favorites) {
        _favoriteIds.add(p.id);
      }
      _isLoaded = true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agrega un producto a los favoritos.
  ///
  /// Llama a POST /api/favorites/{productId}.
  /// Actualiza el estado local inmediatamente para UX responsiva.
  /// NO recarga la lista completa — solo actualiza estado local.
  /// Retorna `true` si fue exitoso.
  Future<bool> addFavorite(int productId) async {
    // Actualizar estado local inmediatamente (optimistic update)
    _favoriteIds.add(productId);
    notifyListeners();

    try {
      await _api.post('/favorites/$productId', {}, auth: true);
      return true;
    } catch (e) {
      // Revertir en caso de error
      _favoriteIds.remove(productId);
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Quita un producto de los favoritos.
  ///
  /// Llama a DELETE /api/favorites/{productId}.
  /// Actualiza el estado local inmediatamente.
  /// Retorna `true` si fue exitoso.
  Future<bool> removeFavorite(int productId) async {
    try {
      await _api.delete('/favorites/$productId', auth: true);
      _favoriteIds.remove(productId);
      _favorites.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Alterna el estado de favorito de un producto.
  ///
  /// Si ya es favorito lo quita, si no lo es lo agrega.
  /// Retorna `true` si la operación fue exitosa.
  Future<bool> toggleFavorite(int productId) async {
    if (isFavorite(productId)) {
      return removeFavorite(productId);
    } else {
      return addFavorite(productId);
    }
  }
}
