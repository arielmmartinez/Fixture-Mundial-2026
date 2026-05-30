import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../../domain/entities/fixture_entities.dart';

class TeamsScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const TeamsScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    
    // Filter teams based on search query
    final filteredTeams = provider.allTeams.where((team) {
      return team.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          team.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          team.group.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort followed first, then by group
    filteredTeams.sort((a, b) {
      if (a.isFollowing != b.isFollowing) {
        return a.isFollowing ? -1 : 1;
      }
      return a.group.compareTo(b.group);
    });

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

            // Hotspots grid for the 8 visible card positions on screen (4 rows of 2 columns)
            final List<Map<String, double>> cardCoordinates = [
              // Row 1
              {'left': 24, 'top': 220}, // Col 1
              {'left': 300, 'top': 220}, // Col 2
              // Row 2
              {'left': 24, 'top': 390}, // Col 1
              {'left': 300, 'top': 390}, // Col 2
              // Row 3
              {'left': 24, 'top': 560}, // Col 1
              {'left': 300, 'top': 560}, // Col 2
              // Row 4
              {'left': 24, 'top': 730}, // Col 1
              {'left': 300, 'top': 730}, // Col 2
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
                    'assets/images/paises_mockup.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // 2. Transparent Interactive Hotspots
                
                // A. Search Bar Input Hotspot (Opens keyboard and performs search query)
                Positioned(
                  left: leftOffset + (24 * scale),
                  top: topOffset + (100 * scale),
                  width: 528 * scale,
                  height: 58 * scale,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    ),
                  ),
                ),

                // B. Interactive Team Grid Cards
                for (int i = 0; i < cardCoordinates.length; i++) ...[
                  if (i < filteredTeams.length) ...[
                    // Card Hotspot (toggles follow on tap)
                    Positioned(
                      left: leftOffset + (cardCoordinates[i]['left']! * scale),
                      top: topOffset + (cardCoordinates[i]['top']! * scale),
                      width: 252 * scale,
                      height: 150 * scale,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          provider.toggleTeamFollowing(filteredTeams[i].id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                filteredTeams[i].isFollowing
                                    ? 'Dejaste de seguir a ${filteredTeams[i].name}'
                                    : 'Siguiendo a ${filteredTeams[i].name} ⭐',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                    // Favorite Toggle Heart Icon Hotspot
                    Positioned(
                      left: leftOffset + ((cardCoordinates[i]['left']! + 200) * scale),
                      top: topOffset + ((cardCoordinates[i]['top']! + 10) * scale),
                      width: 44 * scale,
                      height: 44 * scale,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          provider.toggleTeamFollowing(filteredTeams[i].id);
                        },
                      ),
                    ),
                  ],
                ],

                // C. Bottom Navigation Bar Hotspots (split into 7 equal clickable sections)
                
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
}
