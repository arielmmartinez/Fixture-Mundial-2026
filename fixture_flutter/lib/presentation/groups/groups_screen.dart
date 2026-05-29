import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/match_detail_dialog.dart';
import '../../domain/entities/fixture_entities.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final borderColor = isDark ? BentoColors.bentoBorderDark : BentoColors.bentoBorderLight;

    final standings = provider.groupStandings;
    final groupsList = List.generate(12, (index) => String.fromCharCode(65 + index));

    return Column(
      children: [
        // Tab bar for Groups A to L
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelColor: BentoColors.bentoSlate500,
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: groupsList.map((g) => Tab(text: 'Grupo $g')).toList(),
          ),
        ),

        // Standings and group matches view
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: groupsList.map((groupChar) {
              final groupRows = standings[groupChar] ?? [];
              final groupMatches = provider.allMatches.where((m) => m.group == groupChar).toList();

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Standings Table Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3.0), // Team name
                          1: FlexColumnWidth(0.8), // PJ
                          2: FlexColumnWidth(0.8), // PG
                          3: FlexColumnWidth(0.8), // PE
                          4: FlexColumnWidth(0.8), // PP
                          5: FlexColumnWidth(1.2), // DG
                          6: FlexColumnWidth(1.2), // PTS
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          // Table Header
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                            children: const [
                              _TableCellHeader(text: 'SELECCIÓN', alignLeft: true),
                              _TableCellHeader(text: 'PJ'),
                              _TableCellHeader(text: 'G'),
                              _TableCellHeader(text: 'E'),
                              _TableCellHeader(text: 'P'),
                              _TableCellHeader(text: 'DG'),
                              _TableCellHeader(text: 'PTS'),
                            ],
                          ),

                          // Table Rows (Teams)
                          ...groupRows.map((row) {
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
                              ),
                              children: [
                                // Flag & Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    children: [
                                      Text(row.teamFlag, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          row.teamName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _TableCellBody(text: '${row.played}'),
                                _TableCellBody(text: '${row.won}'),
                                _TableCellBody(text: '${row.drawn}'),
                                _TableCellBody(text: '${row.lost}'),
                                _TableCellBody(
                                  text: (row.goalDifference > 0 ? '+' : '') + '${row.goalDifference}',
                                  textColor: row.goalDifference > 0
                                      ? Colors.green
                                      : row.goalDifference < 0
                                          ? Colors.red
                                          : null,
                                ),
                                _TableCellBody(
                                  text: '${row.points}',
                                  isBold: true,
                                  textColor: primaryColor,
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header for group matches
                  const Text(
                    'Partidos del Grupo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Group Matches List
                  if (groupMatches.isEmpty)
                    const Center(
                      child: Text(
                        'No hay partidos programados para este grupo.',
                        style: TextStyle(color: BentoColors.bentoSlate500, fontSize: 12),
                      ),
                    )
                  else
                    Column(
                      children: groupMatches.map((match) {
                        return MatchCardInline(
                          match: match,
                          onTap: () => _showMatchDetail(context, match, provider),
                          onToggleFavorite: () => provider.toggleFavorite(match.id),
                        );
                      }).toList(),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
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

class _TableCellHeader extends StatelessWidget {
  final String text;
  final bool alignLeft;

  const _TableCellHeader({
    Key? key,
    required this.text,
    this.alignLeft = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: BentoColors.bentoSlate500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TableCellBody extends StatelessWidget {
  final String text;
  final bool isBold;
  final Color? textColor;

  const _TableCellBody({
    Key? key,
    required this.text,
    this.isBold = false,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
        color: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
