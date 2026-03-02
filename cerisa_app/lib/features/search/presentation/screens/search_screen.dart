import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cerisa_app/core/theme/app_theme.dart';
import 'package:cerisa_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:cerisa_app/core/routes/app_routes.dart';
import 'package:cerisa_app/features/search/presentation/screens/search_results_screen.dart';

/// Pantalla de búsqueda y filtrado de productos estilo e-commerce.
///
/// Incluye: campo de búsqueda, búsquedas recientes, filtros por
/// categoría con íconos circulares, rango de precios con slider,
/// filtro por material con checkboxes, y botones de acción.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Filtros
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(20, 150);

  // Búsquedas recientes simuladas
  final List<String> _recentSearches = ['Jarrón azul', 'Set de té', 'Kintsugi', 'Studio Kura'];

  // Categorías con íconos
  static const List<_CategoryItem> _categories = [
    _CategoryItem('Jarrones', Icons.local_florist_rounded),
    _CategoryItem('Platos', Icons.circle, customIcon: true),
    _CategoryItem('Tazas', Icons.coffee_rounded),
    _CategoryItem('Teteras', Icons.emoji_food_beverage_rounded),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final catalog = context.read<CatalogProvider>();
      if (catalog.products.isEmpty) {
        catalog.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra los productos según los criterios activos.
  List<ProductModel> _applyFilters(List<ProductModel> products) {
    return products.where((p) {
      // Filtro por texto de búsqueda
      if (_query.isNotEmpty) {
        final nombre = p.nombre.toLowerCase();
        final desc = (p.descripcion ?? '').toLowerCase();
        final cat = (p.categoria ?? '').toLowerCase();
        if (!nombre.contains(_query) && !desc.contains(_query) && !cat.contains(_query)) {
          return false;
        }
      }

      // Filtro por categoría
      if (_selectedCategory != null) {
        final cat = (p.categoria ?? '').toLowerCase();
        if (!cat.contains(_selectedCategory!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por rango de precio
      if (p.precio < _priceRange.start || p.precio > _priceRange.end) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CatalogProvider>(
          builder: (context, catalog, _) {
            final filtered = _applyFilters(catalog.products);
            final resultCount = filtered.length;

            return Column(
              children: [
                // ── Contenido scrolleable ──
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barra superior
                        _buildTopBar(context),

                        // Campo de búsqueda
                        _buildSearchField(),

                        // Búsquedas recientes
                        if (_query.isEmpty) _buildRecentSearches(),

                        // Divider
                        if (_query.isEmpty) _buildDivider(),

                        // Filtrar por categoría
                        _buildCategoryFilter(),

                        // Rango de precios
                        _buildPriceRange(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Botones fijos abajo ──
                _buildBottomButtons(resultCount),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Barra superior con flecha de retorno y título.
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
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
              'Buscar y Filtrar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 48), // Balance con el botón de atrás
        ],
      ),
    );
  }

  /// Campo de búsqueda con borde naranja/marrón.
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar jarrones, platos, artistas...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary.withValues(alpha: 0.7)),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (value) => setState(() => _query = value.toLowerCase()),
      ),
    );
  }

  /// Sección de búsquedas recientes con chips.
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y "Limpiar todo"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Búsquedas Recientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              GestureDetector(
                onTap: () => setState(() => _recentSearches.clear()),
                child: const Text(
                  'Limpiar todo',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chips de búsquedas recientes
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = term;
                  setState(() => _query = term.toLowerCase());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.7), width: 1),
                  ),
                  child: Text(
                    term,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Línea divisora horizontal.
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Divider(color: AppColors.divider.withValues(alpha: 0.5), height: 1),
    );
  }

  /// Filtro por categoría con íconos circulares.
  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por Categoría',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat.name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = _selectedCategory == cat.name ? null : cat.name;
                  });
                },
                child: Column(
                  children: [
                    // Ícono circular
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.surface,
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.divider.withValues(alpha: 0.5),
                          width: isSelected ? 2.5 : 1.2,
                        ),
                      ),
                      child: Icon(cat.icon, size: 28, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    // Nombre de categoría
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Slider de rango de precios.
  Widget _buildPriceRange() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y rango actual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rango de Precio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                'S/${_priceRange.start.round()} - S/${_priceRange.end.round()}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.divider.withValues(alpha: 0.4),
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 500,
              divisions: 50,
              onChanged: (values) {
                setState(() => _priceRange = values);
              },
            ),
          ),
          // Etiquetas min/max
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('S/0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('S/500+', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botones inferiores: Reset y Mostrar resultados.
  Widget _buildBottomButtons(int resultCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // Botón "Resetear"
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _query = '';
                  _selectedCategory = null;
                  _priceRange = const RangeValues(20, 150);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.7), width: 1.2),
                ),
                child: const Text(
                  'Resetear',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón "Mostrar X Resultados"
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                // Navegar a resultados pasando los filtros activos
                Navigator.pushNamed(
                  context,
                  AppRoutes.searchResults,
                  arguments: SearchResultsArgs(
                    query: _query.isNotEmpty ? _query : null,
                    category: _selectedCategory,
                    priceMin: _priceRange.start,
                    priceMax: _priceRange.end,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Mostrar $resultCount Resultados',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo interno para las categorías con ícono.
class _CategoryItem {
  final String name;
  final IconData icon;
  final bool customIcon;

  const _CategoryItem(this.name, this.icon, {this.customIcon = false});
}
