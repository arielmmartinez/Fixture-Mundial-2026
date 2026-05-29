import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/match_detail_dialog.dart';
import '../../domain/entities/fixture_entities.dart';

class FixtureScreen extends StatefulWidget {
  const FixtureScreen({Key? key}) : super(key: key);

  @override
  _FixtureScreenState createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final borderColor = isDark ? BentoColors.bentoBorderDark : BentoColors.bentoBorderLight;

    final filtered = provider.filteredMatches;

    return Column(
      children: [
        // Search & Filter header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Buscar selección, estadio, ciudad...',
                    hintStyle: const TextStyle(fontSize: 13, color: BentoColors.bentoSlate500),
                    prefixIcon: const Icon(Icons.search, size: 20, color: BentoColors.bentoSlate500),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Filtrar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),
        ),

        // Filter Drawer Panel
        if (_showFilters)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtros de Búsqueda',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        provider.clearAllFilters();
                        _searchController.clear();
                      },
                      child: const Text(
                        'Limpiar todo',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter 1: Group
                const Text('Grupo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: BentoColors.bentoSlate500)),
                const SizedBox(height: 6),
                _buildScrollableRow(
                  options: ['Todos'] + List.generate(12, (index) => 'Grupo ${String.fromCharCode(65 + index)}'),
                  selected: provider.filterState.group == 'Todos' ? 'Todos' : 'Grupo ${provider.filterState.group}',
                  onSelect: (opt) {
                    if (opt == 'Todos') {
                      provider.setGroupFilter('Todos');
                    } else {
                      provider.setGroupFilter(opt.replaceAll('Grupo ', ''));
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Filter 2: Host Country
                const Text('Sede', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: BentoColors.bentoSlate500)),
                const SizedBox(height: 6),
                _buildScrollableRow(
                  options: ['Todos', 'México', 'USA', 'Canadá'],
                  selected: provider.filterState.country,
                  onSelect: (opt) => provider.setCountryFilter(opt),
                ),
              ],
            ),
          ),

        // Result count banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${filtered.length} partidos encontrados',
                style: const TextStyle(fontSize: 11, color: BentoColors.bentoSlate500, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚽', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'No se encontraron partidos con los filtros aplicados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final match = filtered[index];
                    return MatchCard(
                      match: match,
                      onTap: () => _showMatchDetail(context, match, provider),
                    );
                  },
                ),
        )
      ],
    );
  }

  Widget _buildScrollableRow({
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
  }) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final opt = options[index];
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMatchDetail(BuildContext context, Match match, FixtureProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return MatchDetailDialog(
          match: match,
          use24H: provider.use24HourFormat,
          onToggleFavorite: () => provider.toggleFavorite(match.id),
          onToggleReminder: () => provider.toggleReminder(match.id),
          onUpdateScore: (home, away, status) {
            provider.updateScore(match.id, home, away, status);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Partido simulado exitosamente'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}
