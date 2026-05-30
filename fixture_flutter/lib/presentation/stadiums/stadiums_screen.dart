import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../../domain/entities/fixture_entities.dart';

class StadiumsScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const StadiumsScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final stadiums = provider.allStadiums;

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

            // Hotspots grid for the 3 visible card positions on screen
            final List<Map<String, double>> cardCoordinates = [
              {'left': 24, 'top': 200, 'height': 230}, // Card 1 (Azteca)
              {'left': 24, 'top': 450, 'height': 230}, // Card 2 (MetLife)
              {'left': 24, 'top': 700, 'height': 200}, // Card 3 (SoFi)
            ];

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
                    'assets/images/estadios_mockup.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // 2. Transparent Interactive Hotspots
                for (int i = 0; i < cardCoordinates.length; i++) ...[
                  if (i < stadiums.length) ...[
                    Positioned(
                      left: leftOffset + (cardCoordinates[i]['left']! * scale),
                      top: topOffset + (cardCoordinates[i]['top']! * scale),
                      width: 528 * scale,
                      height: cardCoordinates[i]['height']! * scale,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _showStadiumDetail(context, stadiums[i]);
                        },
                      ),
                    ),
                  ],
                ],

                // 3. Bottom Navigation Bar Hotspots (split into 7 equal clickable sections)
                
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

  void _showStadiumDetail(BuildContext context, Stadium stadium) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.stadium, color: Color(0xFF00E5FF), size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stadium.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📍 Sede: ${stadium.city}, ${stadium.country}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '👥 Capacidad: ${stadium.capacity.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} espectadores',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                stadium.description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
