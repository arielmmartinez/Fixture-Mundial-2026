import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/match_detail_dialog.dart';
import '../../domain/entities/fixture_entities.dart' as fixture_entities;

class FavoritesScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const FavoritesScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);

    // Filter dynamic matches in real-time
    final favoriteMatches = provider.allMatches.where((m) => m.isFavorite).toList();
    final reminderMatches = provider.allMatches.where((m) => m.reminderEnabled).toList();

    final activeMatches = _tabController.index == 0 ? favoriteMatches : reminderMatches;

    return Scaffold(
      extendBody: true,
      backgroundColor: BentoColors.pitchDark, // Dark background to fill margins
      body: SafeArea(
        top: true,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double parentWidth = constraints.maxWidth;
            final double parentHeight = constraints.maxHeight;

            // Mockup resolution: 576 x 1024
            const double mockupWidth = 576.0;
            const double mockupHeight = 1024.0;
            const double imageAspectRatio = mockupWidth / mockupHeight;

            // Calculate actual fitted dimensions of Image.asset using BoxFit.contain
            double displayedWidth;
            double displayedHeight;

            if (parentWidth / parentHeight > imageAspectRatio) {
              displayedHeight = parentHeight;
              displayedWidth = parentHeight * imageAspectRatio;
            } else {
              displayedWidth = parentWidth;
              displayedHeight = parentWidth / imageAspectRatio;
            }

            // Centering offset
            final double leftOffset = (parentWidth - displayedWidth) / 2.0;
            const double topOffset = 0.0;

            // Scale factor based on the actual displayed width
            final double scale = displayedWidth / mockupWidth;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Pixel-perfect Mockup Background Image
                Positioned(
                  left: leftOffset,
                  top: topOffset,
                  width: displayedWidth,
                  height: displayedHeight,
                  child: Image.asset(
                    'assets/images/favorites_screen.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // 2. Custom Animated Tab Bar Overlay (Masking static tab bar and reflecting live data)
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (90 * scale),
                  width: 528 * scale,
                  height: 50 * scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1A), // Pure pitch dark to match mockup background
                      borderRadius: BorderRadius.circular(25 * scale),
                      border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                    ),
                    child: Stack(
                      children: [
                        // Sliding active tab indicator capsule
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          left: _tabController.index == 0 ? 0 : 264 * scale,
                          width: 264 * scale,
                          height: 50 * scale,
                          child: Container(
                            margin: EdgeInsets.all(4 * scale),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF047857), // Forest green
                                  Color(0xFF10B981), // Glowing Emerald green
                                ],
                              ),
                              borderRadius: BorderRadius.circular(21 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.35),
                                  blurRadius: 10 * scale,
                                  spreadRadius: 1 * scale,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tab Buttons with dynamic live match counts
                        Row(
                          children: [
                            // Tab 0: Favoritos
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _tabController.animateTo(0);
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 14 * scale,
                                        color: _tabController.index == 0
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.35),
                                      ),
                                      SizedBox(width: 6 * scale),
                                      Text(
                                        'Partidos Favoritos (${favoriteMatches.length})',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5 * scale,
                                          fontWeight: FontWeight.w900,
                                          color: _tabController.index == 0
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Tab 1: Alertas
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _tabController.animateTo(1);
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications_active_rounded,
                                        size: 14 * scale,
                                        color: _tabController.index == 1
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.35),
                                      ),
                                      SizedBox(width: 6 * scale),
                                      Text(
                                        'Alertas Activas (${reminderMatches.length})',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5 * scale,
                                          fontWeight: FontWeight.w900,
                                          color: _tabController.index == 1
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Dynamic Favorite Matches list or Mockup Empty State
                if (activeMatches.isEmpty) ...[
                  // Transparent empty state cards hotspots mapped directly over empty state illustration
                  // Card 1: Ir al Fixture
                  Positioned(
                    left: leftOffset + (48 * scale),
                    top: topOffset + (590 * scale),
                    width: 224 * scale,
                    height: 138 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => widget.onNavigate(1), // Navigates to Fixture
                    ),
                  ),
                  // Card 2: Ir al Inicio
                  Positioned(
                    left: leftOffset + (304 * scale),
                    top: topOffset + (590 * scale),
                    width: 224 * scale,
                    height: 138 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => widget.onNavigate(0), // Navigates to Inicio
                    ),
                  ),
                ] else ...[
                  // Overlays and covers the mockup's empty state area with live matches list
                  Positioned(
                    left: leftOffset + (24 * scale),
                    top: topOffset + (160 * scale),
                    width: 528 * scale,
                    height: 730 * scale,
                    child: Container(
                      color: const Color(0xFF070B14), // Matches deep dark mockup canvas background
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        physics: const BouncingScrollPhysics(),
                        itemCount: activeMatches.length,
                        itemBuilder: (context, index) {
                          final match = activeMatches[index];
                          return MatchCard(
                            match: match,
                            onTap: () => _showMatchDetail(context, match, provider),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // 4. Bottom Navigation Bar Hotspots (split into 7 equal clickable sections)
                
                // Tab 0: Inicio
                Positioned(
                  left: leftOffset + (0 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(0),
                  ),
                ),

                // Tab 1: Fixture
                Positioned(
                  left: leftOffset + (82.2 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(1),
                  ),
                ),

                // Tab 2: Grupos
                Positioned(
                  left: leftOffset + (164.4 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(2),
                  ),
                ),

                // Tab 3: Países
                Positioned(
                  left: leftOffset + (246.6 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(3),
                  ),
                ),

                // Tab 4: Estadios
                Positioned(
                  left: leftOffset + (328.8 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(4),
                  ),
                ),

                // Tab 5: Favoritos
                Positioned(
                  left: leftOffset + (411.0 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(5),
                  ),
                ),

                // Tab 6: Ajustes
                Positioned(
                  left: leftOffset + (493.2 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.8 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNavigate(6),
                  ),
                ),
              ],
            );
          },
        ),
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
