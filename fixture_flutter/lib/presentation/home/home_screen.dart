import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../../domain/entities/fixture_entities.dart' as fixture_entities;
import '../providers/fixture_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/match_detail_dialog.dart';
import '../widgets/premium_header.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? BentoColors.bentoBorderDark : BentoColors.bentoBorderLight;
    final primaryColor = Theme.of(context).primaryColor;

    final nextMatch = provider.allMatches.firstWhere(
      (m) => m.status == 'próximo',
      orElse: () => provider.allMatches.isNotEmpty ? provider.allMatches.first : fixture_entities.Match(
        id: 'none',
        matchNumber: 0,
        group: '',
        homeTeam: '???',
        awayTeam: '???',
        homeFlag: '🏳️',
        awayFlag: '🏳️',
        date: '',
        localTime: '',
        venueTime: '',
        stadium: '',
        city: '',
        country: '',
        venue: '',
        status: 'próximo',
      ),
    );

    final openingMatches = provider.allMatches.take(5).toList();

    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // Edge-to-edge layout for the header
        children: [
          // 1. Premium Header (Wavy Flag & Gold Trophy Banner)
          const PremiumHeader(subtitle: 'FASE DE GRUPOS'),

          // Rest of Content inside responsive padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bento Block 1: Premium Countdown Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF090E1A), // Deep Midnight Navy
                        Color(0xFF151D30), // Cool Metallic Navy
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: BentoColors.bentoBorderLight, width: 1.5), // Shiny Gold border
                    boxShadow: [
                      BoxShadow(
                        color: BentoColors.soccerGreen.withOpacity(0.08),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Golden Trophy Watermark Outline (Decorative silhouette)
                      Positioned(
                        right: 20,
                        bottom: -10,
                        top: -10,
                        child: Opacity(
                          opacity: 0.08,
                          child: Icon(
                            Icons.emoji_events,
                            size: 150,
                            color: BentoColors.worldCupGold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.hourglass_empty,
                                  color: BentoColors.worldCupGold,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'CUENTA REGRESIVA',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.black,
                                    color: BentoColors.worldCupGold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.daysToWorldCup} DÍAS',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 40,
                                fontWeight: FontWeight.black,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: BentoColors.soccerGreen,
                                    offset: Offset(0, 0),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Para el pitazo inicial en el Estadio Azteca',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: BentoColors.bentoSlate500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Fase de grupos: 11 al 27 de junio de 2026',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: BentoColors.bentoSlate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bento Block 2 & 3: Side-by-Side Cards (col-span-1 in Bento layout)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Next Match Bento Box (Crema White/Gold)
                    Expanded(
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: BentoColors.softWhite,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: BentoColors.bentoBorderLight, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: nextMatch.id != 'none'
                                ? () => _showMatchDetail(context, nextMatch, provider)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: BentoColors.worldCupGold, size: 10),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'PRÓXIMO DESTACADO',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 8,
                                          fontWeight: FontWeight.black,
                                          color: BentoColors.bentoSlate500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (nextMatch.id != 'none')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            _buildCircularFlag(nextMatch.homeFlag),
                                            const SizedBox(height: 4),
                                            Text(
                                              nextMatch.homeTeam,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 10,
                                                fontWeight: FontWeight.black,
                                                color: BentoColors.deepSlate,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          'VS',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.black,
                                            fontStyle: FontStyle.italic,
                                            color: BentoColors.worldCupGold,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            _buildCircularFlag(nextMatch.awayFlag),
                                            const SizedBox(height: 4),
                                            Text(
                                              nextMatch.awayTeam,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 10,
                                                fontWeight: FontWeight.black,
                                                color: BentoColors.deepSlate,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  else
                                    const Text(
                                      'No Programado',
                                      style: TextStyle(fontSize: 11, color: BentoColors.bentoSlate500),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Group Stages Bento Box (Neon Turquesa Gradient)
                    Expanded(
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0295A3), // Dark turquoise
                              BentoColors.soccerGreen, // Neon Turquoise
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: BentoColors.electricGreen.withOpacity(0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BentoColors.soccerGreen.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => onNavigate(2), // Groups tab
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.groups, color: Colors.white, size: 10),
                                      const SizedBox(width: 4),
                                      Text(
                                        'FASE DE GRUPOS',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 8,
                                          fontWeight: FontWeight.black,
                                          color: Colors.white.withOpacity(0.85),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '12 Grupos',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 20,
                                          fontWeight: FontWeight.black,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 1),
                                      Text(
                                        '48 países buscando la copa.',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bento Block 4: Shortcut Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BentoColors.bentoBorderLight, width: 1.5),
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E1726), // Dark slate
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.calendar_today, size: 14, color: BentoColors.worldCupGold),
                          label: const Text(
                            'Fixture completo',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.black),
                          ),
                          onPressed: () => onNavigate(1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BentoColors.bentoBorderLight, width: 1.5),
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BentoColors.softWhite, // Crema
                            foregroundColor: BentoColors.deepSlate,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.star, color: BentoColors.worldCupGold, size: 14),
                          label: const Text(
                            'Favoritos',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.black),
                          ),
                          onPressed: () => onNavigate(5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bento Block 5: Header and Opening Matches
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Partidos de Apertura',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.black,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onNavigate(1),
                      child: const Row(
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.black,
                              color: BentoColors.electricGreen,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right, color: BentoColors.electricGreen, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: openingMatches.map((match) {
                    return MatchCardInline(
                      match: match,
                      onTap: () => _showMatchDetail(context, match, provider),
                      onToggleFavorite: () => provider.toggleFavorite(match.id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Bento Block 6: Local Offline Active Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1726), // Dark slate navy
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: BentoColors.bentoBorderLight.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: BentoColors.electricGreen, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Modo Offline Activo',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.black,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'El fixture y las simulaciones se guardan de manera local. Puedes simular marcadores o configurar alarmas sin conexión a internet.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          height: 1.4,
                          color: BentoColors.bentoSlate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bento Block 7: Disclaimer Footer
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Esta aplicación no está afiliada ni patrocinada por la FIFA.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: BentoColors.bentoSlate500),
                      ),
                      Text(
                        'Fixture y sedes sujetos a modificaciones oficiales.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: BentoColors.bentoSlate500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularFlag(String flag) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: BentoColors.bentoBorderLight, width: 1.2),
      ),
      child: Text(
        flag,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _showMatchDetail(BuildContext context, fixture_entities.Match match, FixtureProvider provider) {
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
