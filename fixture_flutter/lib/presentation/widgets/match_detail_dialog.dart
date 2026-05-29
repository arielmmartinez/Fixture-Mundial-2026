import 'package:flutter/material.dart';
import '../../domain/entities/fixture_entities.dart';
import '../../core/theme/bento_theme.dart';

class MatchDetailDialog extends StatefulWidget {
  final Match match;
  final bool use24H;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleReminder;
  final Function(int homeScore, int awayScore, String status) onUpdateScore;

  const MatchDetailDialog({
    Key? key,
    required this.match,
    required this.use24H,
    required this.onToggleFavorite,
    required this.onToggleReminder,
    required this.onUpdateScore,
  }) : super(key: key);

  @override
  _MatchDetailDialogState createState() => _MatchDetailDialogState();
}

class _MatchDetailDialogState extends State<MatchDetailDialog> {
  late int _homeScore;
  late int _awayScore;
  late String _status;

  @override
  void initState() {
    super.initState();
    _homeScore = widget.match.homeScore;
    _awayScore = widget.match.awayScore;
    _status = widget.match.status;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalle del Partido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.match.reminderEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: widget.match.reminderEnabled ? primaryColor : BentoColors.bentoSlate500,
                        ),
                        onPressed: () {
                          widget.onToggleReminder();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          widget.match.isFavorite ? Icons.star : Icons.star_border,
                          color: widget.match.isFavorite ? Colors.amber : BentoColors.bentoSlate500,
                        ),
                        onPressed: () {
                          widget.onToggleFavorite();
                          setState(() {});
                        },
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Match info
              Center(
                child: Column(
                  children: [
                    Text(
                      'PARTIDO #${widget.match.matchNumber} - GRUPO ${widget.match.group}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.match.date} a las ${widget.match.localTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: BentoColors.bentoSlate500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.match.stadium} (${widget.match.city}, ${widget.match.country})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: BentoColors.bentoSlate500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Team comparison and score adjustment panel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home Team
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.match.homeFlag, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          widget.match.homeTeam,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildScoreButton(Icons.remove, () {
                              if (_homeScore > 0) {
                                setState(() => _homeScore--);
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_homeScore',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ),
                            _buildScoreButton(Icons.add, () {
                              setState(() => _homeScore++);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // VS Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: BentoColors.bentoSlate500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  // Away Team
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.match.awayFlag, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          widget.match.awayTeam,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildScoreButton(Icons.remove, () {
                              if (_awayScore > 0) {
                                setState(() => _awayScore--);
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_awayScore',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ),
                            _buildScoreButton(Icons.add, () {
                              setState(() => _awayScore++);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Match status selector
              const Text(
                'Estado del Partido',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: BentoColors.bentoSlate500),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: primaryColor.withOpacity(0.2),
                  selectedForegroundColor: primaryColor,
                ),
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'próximo', label: Text('Próximo', style: TextStyle(fontSize: 11))),
                  ButtonSegment<String>(value: 'en vivo', label: Text('En Vivo', style: TextStyle(fontSize: 11))),
                  ButtonSegment<String>(value: 'finalizado', label: Text('Finalizado', style: TextStyle(fontSize: 11))),
                ],
                selected: <String>{_status},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _status = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notes Card
              if (widget.match.notes.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.match.notes,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Actions buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        widget.onUpdateScore(_homeScore, _awayScore, _status);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Guardar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreButton(IconData icon, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? BentoColors.bentoBorderDark : BentoColors.bentoBorderLight.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }
}
