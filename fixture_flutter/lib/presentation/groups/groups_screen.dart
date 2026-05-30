import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_detail_dialog.dart';
import '../../domain/entities/fixture_entities.dart';

class GroupsScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const GroupsScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    
    // Resolve matches dynamically based on current selected group tab (A to L)
    final String groupChar = String.fromCharCode(65 + _tabController.index);
    final groupMatches = provider.allMatches.where((m) => m.group == groupChar).toList();
    
    final Match? match1 = groupMatches.isNotEmpty ? groupMatches[0] : null;
    final Match? match2 = groupMatches.length > 1 ? groupMatches[1] : null;

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

            // Centering offset (Alignment.topCenter means left offsets are centered, top is 0)
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
                    'assets/images/grupos_mockup.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // 2. Transparent Interactive Hotspots (aligned dynamically based on absolute scale and offsets)
                
                // A. Group Selector Tabs (A to F horizontal hotspots based on x slices)
                // Tab A (index 0)
                Positioned(
                  left: leftOffset + (0 * scale),
                  top: topOffset + (110 * scale),
                  width: 96 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {});
                    },
                  ),
                ),
                // Tab B (index 1)
                Positioned(
                  left: leftOffset + (96 * scale),
                  top: topOffset + (110 * scale),
                  width: 96 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {});
                    },
                  ),
                ),
                // Tab C (index 2)
                Positioned(
                  left: leftOffset + (192 * scale),
                  top: topOffset + (110 * scale),
                  width: 96 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _tabController.animateTo(2);
                      setState(() {});
                    },
                  ),
                ),
                // Tab D (index 3)
                Positioned(
                  left: leftOffset + (288 * scale),
                  top: topOffset + (110 * scale),
                  width: 96 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _tabController.animateTo(3);
                      setState(() {});
                    },
                  ),
                ),
                // Tab E (index 4)
                Positioned(
                  left: leftOffset + (384 * scale),
                  top: topOffset + (110 * scale),
                  width: 96 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _tabController.animateTo(4);
                      setState(() {});
                    },
                  ),
                ),
                // Tab F (index 5)
                Positioned(
                  left: leftOffset + (480 * scale),
                  top: topOffset + (110 * scale),
                  width: 96 * scale,
                  height: 40 * scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _tabController.animateTo(5);
                      setState(() {});
                    },
                  ),
                ),

                // B. Match 1 Card Hotspot (Loads active group matches[0])
                if (match1 != null) ...[
                  Positioned(
                    left: leftOffset + (20 * scale),
                    top: topOffset + (636 * scale),
                    width: 536 * scale,
                    height: 98 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _showMatchDetail(context, match1, provider),
                    ),
                  ),
                  // Match 1: Favorite Toggle Hotspot
                  Positioned(
                    left: leftOffset + (472 * scale),
                    top: topOffset + (656 * scale),
                    width: 48 * scale,
                    height: 48 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => provider.toggleFavorite(match1.id),
                      child: Center(
                        child: match1.isFavorite
                            ? Icon(Icons.star, color: const Color(0xFFFFD700), size: 22 * scale)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],

                // C. Match 2 Card Hotspot (Loads active group matches[1])
                if (match2 != null) ...[
                  Positioned(
                    left: leftOffset + (20 * scale),
                    top: topOffset + (744 * scale),
                    width: 536 * scale,
                    height: 98 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _showMatchDetail(context, match2, provider),
                    ),
                  ),
                  // Match 2: Favorite Toggle Hotspot
                  Positioned(
                    left: leftOffset + (472 * scale),
                    top: topOffset + (764 * scale),
                    width: 48 * scale,
                    height: 48 * scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => provider.toggleFavorite(match2.id),
                      child: Center(
                        child: match2.isFavorite
                            ? Icon(Icons.star, color: const Color(0xFFFFD700), size: 22 * scale)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],

                // D. Bottom Navigation Bar Hotspots (split into 7 equal clickable sections)
                
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
