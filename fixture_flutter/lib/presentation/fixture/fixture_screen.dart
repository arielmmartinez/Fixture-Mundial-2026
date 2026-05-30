import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_detail_dialog.dart';
import '../../domain/entities/fixture_entities.dart';

class FixtureScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const FixtureScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  _FixtureScreenState createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    
    // Grab the actual mock matches dynamically so we keep all state simulation functional!
    final matches = provider.allMatches;
    
    // Resolve matches dynamically based on mockup index
    // Mockup lists:
    // 1. CAN vs AUS (Match id: "m2")
    // 2. USA vs KSA (Match id: "m3")
    // 3. ARG vs NGA (Match id: "m4")
    final Match match1 = matches.firstWhere((m) => m.id == 'm2', orElse: () => matches.isNotEmpty ? matches.first : _placeholderMatch('m2', 'CAN', 'AUS', '🇨🇦', '🇦🇺', '17:00'));
    final Match match2 = matches.firstWhere((m) => m.id == 'm3', orElse: () => matches.isNotEmpty ? matches.first : _placeholderMatch('m3', 'USA', 'KSA', '🇺🇸', '🇸🇦', '19:00'));
    final Match match3 = matches.firstWhere((m) => m.id == 'm4', orElse: () => matches.isNotEmpty ? matches.first : _placeholderMatch('m4', 'ARG', 'NGA', '🇦🇷', '🇳🇬', '15:00'));

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

            // Centering offset (Alignment.topCenter alignment means left centers, top starts exactly at 0)
            final double leftOffset = (parentWidth - displayedWidth) / 2.0;
            const double topOffset = 0.0;

            // Scale factor based on the actual displayed width
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
                    'assets/images/fixture_mockup.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // 2. Transparent Interactive Hotspots (aligned dynamically based on absolute scale and offsets)

                // A. Search Bar Input Hotspot (Opens keyboard and performs search query)
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (200 * scale),
                  width: 380 * scale,
                  height: 58 * scale,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => provider.setSearchQuery(val),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    ),
                  ),
                ),

                // B. "Filtrar" Button Hotspot
                Positioned(
                  left: leftOffset + (422 * scale),
                  top: topOffset + (200 * scale),
                  width: 130 * scale,
                  height: 58 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // Trigger a toggle or reset on sede filter
                      provider.setCountryFilter(provider.filterState.country == 'Todos' ? 'México' : 'Todos');
                    },
                  ),
                ),

                // C. Chips: Grupo (Hotspot selectors for groups A, B, C, D)
                // Chip "Todos" (Grupo)
                Positioned(
                  left: leftOffset + (46 * scale),
                  top: topOffset + (344 * scale),
                  width: 90 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.setGroupFilter('Todos'),
                  ),
                ),
                // Chip "Grupo A"
                Positioned(
                  left: leftOffset + (146 * scale),
                  top: topOffset + (344 * scale),
                  width: 95 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.setGroupFilter('A'),
                  ),
                ),
                // Chip "Grupo B"
                Positioned(
                  left: leftOffset + (252 * scale),
                  top: topOffset + (344 * scale),
                  width: 95 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.setGroupFilter('B'),
                  ),
                ),

                // D. Chips: Sede (Hotspot selectors for México, USA, Canadá)
                // Chip "Todos" (Sede)
                Positioned(
                  left: leftOffset + (46 * scale),
                  top: topOffset + (430 * scale),
                  width: 90 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.setCountryFilter('Todos'),
                  ),
                ),
                // Chip "México"
                Positioned(
                  left: leftOffset + (146 * scale),
                  top: topOffset + (430 * scale),
                  width: 95 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.setCountryFilter('México'),
                  ),
                ),
                // Chip "USA"
                Positioned(
                  left: leftOffset + (252 * scale),
                  top: topOffset + (430 * scale),
                  width: 75 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.setCountryFilter('USA'),
                  ),
                ),

                // E. "Limpiar todo" Link Hotspot
                Positioned(
                  left: leftOffset + (420 * scale),
                  top: topOffset + (284 * scale),
                  width: 130 * scale,
                  height: 35 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      provider.clearAllFilters();
                      _searchController.clear();
                    },
                  ),
                ),

                // F. Match 1 Card Hotspot (CAN vs AUS)
                Positioned(
                  left: leftOffset + (20 * scale),
                  top: topOffset + (530 * scale),
                  width: 536 * scale,
                  height: 76 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showMatchDetail(context, match1, provider),
                  ),
                ),
                // Match 1: Favorite Toggle Hotspot
                Positioned(
                  left: leftOffset + (480 * scale),
                  top: topOffset + (534 * scale),
                  width: 40 * scale,
                  height: 34 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.toggleFavorite(match1.id),
                  ),
                ),

                // G. Match 2 Card Hotspot (USA vs KSA)
                Positioned(
                  left: leftOffset + (20 * scale),
                  top: topOffset + (616 * scale),
                  width: 536 * scale,
                  height: 148 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showMatchDetail(context, match2, provider),
                  ),
                ),
                // Match 2: Notification Toggle Hotspot
                Positioned(
                  left: leftOffset + (412 * scale),
                  top: topOffset + (714 * scale),
                  width: 48 * scale,
                  height: 44 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.toggleReminder(match2.id),
                  ),
                ),
                // Match 2: Favorite Toggle Hotspot
                Positioned(
                  left: leftOffset + (472 * scale),
                  top: topOffset + (714 * scale),
                  width: 48 * scale,
                  height: 44 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.toggleFavorite(match2.id),
                  ),
                ),

                // H. Match 3 Card Hotspot (ARG vs NGA)
                Positioned(
                  left: leftOffset + (20 * scale),
                  top: topOffset + (780 * scale),
                  width: 536 * scale,
                  height: 148 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showMatchDetail(context, match3, provider),
                  ),
                ),
                // Match 3: Notification Toggle Hotspot
                Positioned(
                  left: leftOffset + (412 * scale),
                  top: topOffset + (878 * scale),
                  width: 48 * scale,
                  height: 44 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.toggleReminder(match3.id),
                  ),
                ),
                // Match 3: Favorite Toggle Hotspot
                Positioned(
                  left: leftOffset + (472 * scale),
                  top: topOffset + (878 * scale),
                  width: 48 * scale,
                  height: 44 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => provider.toggleFavorite(match3.id),
                  ),
                ),

                // I. Bottom Navigation Bar Hotspots (split into 7 equal clickable sections)
                
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

  Match _placeholderMatch(String id, String home, String away, String hFlag, String aFlag, String time) {
    return Match(
      id: id,
      matchNumber: 1,
      group: 'A',
      homeTeam: home,
      awayTeam: away,
      homeFlag: hFlag,
      awayFlag: aFlag,
      date: '2026-06-11',
      localTime: time,
      venueTime: time,
      stadium: 'Estadio Azteca',
      city: 'CDMX',
      country: 'México',
      venue: 'Sede Azteca',
      status: 'próximo',
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
