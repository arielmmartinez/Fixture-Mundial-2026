import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/match_detail_dialog.dart';
import '../../domain/entities/fixture_entities.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final favoriteMatches = provider.allMatches.where((m) => m.isFavorite).toList();
    final reminderMatches = provider.allMatches.where((m) => m.reminderEnabled).toList();

    return Column(
      children: [
        // Tab bar to select between Favorites and Reminders
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelColor: BentoColors.bentoSlate500,
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Partidos Favoritos'),
              Tab(text: 'Alertas Activas'),
            ],
          ),
        ),

        // Tabs View Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Favorites List
              _buildMatchesList(
                matches: favoriteMatches,
                emptyEmoji: '⭐',
                emptyTitle: 'Sin favoritos guardados',
                emptySubtitle: 'Marca partidos con la estrella desde el fixture o el inicio para verlos de forma rápida aquí.',
                provider: provider,
              ),

              // Tab 2: Reminders List
              _buildMatchesList(
                matches: reminderMatches,
                emptyEmoji: '🔔',
                emptyTitle: 'Sin alertas programadas',
                emptySubtitle: 'Activa la campana en cualquier partido para recibir notificaciones automáticas 15 minutos antes del inicio.',
                provider: provider,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesList({
    required List<Match> matches,
    required String emptyEmoji,
    required String emptyTitle,
    required String emptySubtitle,
    required FixtureProvider provider,
  }) {
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emptyEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: BentoColors.bentoSlate500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          match: match,
          onTap: () => _showMatchDetail(context, match, provider),
        );
      },
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
