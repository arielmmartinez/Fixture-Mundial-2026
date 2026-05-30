import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../../domain/entities/fixture_entities.dart' as fixture_entities;
import '../providers/fixture_provider.dart';
import '../widgets/match_detail_dialog.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);

    // Fetch opening matches to open actual details dynamically!
    final openingMatches = provider.allMatches.take(3).toList();

    return Scaffold(
      extendBody: true,
      backgroundColor: BentoColors.pitchDark, // Dark background to fill any outer spaces
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

            // Calculate actual fitted width and height of Image.asset using BoxFit.contain
            double displayedWidth;
            double displayedHeight;

            if (parentWidth / parentHeight > imageAspectRatio) {
              // Screen is wider/shorter than aspect ratio (iPad or wide device): height fills, width is constrained
              displayedHeight = parentHeight;
              displayedWidth = parentHeight * imageAspectRatio;
            } else {
              // Screen is taller than aspect ratio (Standard iPhone): width fills, height is constrained
              displayedWidth = parentWidth;
              displayedHeight = parentWidth / imageAspectRatio;
            }

            // Calculate centering offset (alignment: Alignment.topCenter)
            final double leftOffset = (parentWidth - displayedWidth) / 2.0;
            const double topOffset = 0.0; // Since it is topCenter, y starts exactly at 0

            // Dynamic scale factor based on the actual displayed width
            final double scale = displayedWidth / mockupWidth;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Pixel-perfect Mockup Background Image (Entire image fitted, no zoom, no crop)
                Positioned(
                  left: leftOffset,
                  top: topOffset,
                  width: displayedWidth,
                  height: displayedHeight,
                  child: Image.asset(
                    'assets/images/home_inicio_mockup.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // 2. Transparent Interactive Hotspots (aligned dynamically based on absolute scale and offsets)

                // A. Fixture completo Button Hotspot
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (576 * scale),
                  width: 252 * scale,
                  height: 70 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onNavigate(1),
                  ),
                ),

                // B. Favoritos Button Hotspot
                Positioned(
                  left: leftOffset + (300 * scale),
                  top: topOffset + (576 * scale),
                  width: 252 * scale,
                  height: 70 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onNavigate(5),
                  ),
                ),

                // C. "Ver todos" Link Hotspot
                Positioned(
                  left: leftOffset + (450 * scale),
                  top: topOffset + (650 * scale),
                  width: 110 * scale,
                  height: 35 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onNavigate(1),
                  ),
                ),

                // D. Match 1 Card Hotspot (MEX vs ECU)
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (690 * scale),
                  width: 528 * scale,
                  height: 60 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (openingMatches.isNotEmpty) {
                        _showMatchDetail(context, openingMatches[0], provider);
                      }
                    },
                  ),
                ),

                // E. Match 2 Card Hotspot (CAN vs AUS)
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (760 * scale),
                  width: 528 * scale,
                  height: 60 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (openingMatches.length > 1) {
                        _showMatchDetail(context, openingMatches[1], provider);
                      }
                    },
                  ),
                ),

                // F. Match 3 Card Hotspot (USA vs KSA)
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (830 * scale),
                  width: 528 * scale,
                  height: 60 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (openingMatches.length > 2) {
                        _showMatchDetail(context, openingMatches[2], provider);
                      }
                    },
                  ),
                ),

                // G. Bottom Navigation Bar Hotspots (split into 7 equal clickable sections)
                
                // Tab 0: Inicio
                Positioned(
                  left: leftOffset + (0 * scale),
                  top: topOffset + (906 * scale),
                  width: 82.2 * scale,
                  height: 118 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => onNavigate(0),
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
                    onTap: () => onNavigate(1),
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
                    onTap: () => onNavigate(2),
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
                    onTap: () => onNavigate(3),
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
                    onTap: () => onNavigate(4),
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
                    onTap: () => onNavigate(5),
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
                    onTap: () => onNavigate(6),
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
