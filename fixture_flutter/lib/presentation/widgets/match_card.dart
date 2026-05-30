import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/fixture_entities.dart';
import '../../core/theme/bento_theme.dart';
import '../providers/fixture_provider.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const MatchCard({
    Key? key,
    required this.match,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BentoColors.softWhite, // Crema premium card background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BentoColors.bentoBorderLight, width: 1.5), // Shiny Gold border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: BentoColors.worldCupGold.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            key: ValueKey('match_${match.id}'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Group and Stadium)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF047857).withOpacity(0.12), // Turquesa/Emerald glow background
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BentoColors.soccerGreen.withOpacity(0.5), width: 1),
                      ),
                      child: const Text(
                        'FASE DE GRUPOS',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF047857),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '${match.city.toUpperCase()}, ${match.country.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: BentoColors.bentoSlate500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Teams and Scores
                Row(
                  children: [
                    // Home Team
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            match.homeTeam,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: BentoColors.deepSlate, // High contrast text
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildCircularFlag(match.homeFlag),
                        ],
                      ),
                    ),

                    // Score or Time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: match.status == 'próximo'
                          ? Column(
                              children: [
                                Text(
                                  match.localTime,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: BentoColors.deepSlate,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  match.date,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 8,
                                    color: BentoColors.bentoSlate500,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Text(
                                  '${match.homeScore} - ${match.awayScore}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: match.status == 'en vivo'
                                        ? Colors.red
                                        : BentoColors.deepSlate,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: match.status == 'en vivo'
                                        ? Colors.red.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    match.status.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 7,
                                      fontWeight: FontWeight.w900,
                                      color: match.status == 'en vivo' ? Colors.red : BentoColors.bentoSlate500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // Away Team
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildCircularFlag(match.awayFlag),
                          const SizedBox(width: 10),
                          Text(
                            match.awayTeam,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: BentoColors.deepSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Footer (Stadium Description & Actions)
                const Divider(height: 1, color: BentoColors.bentoBorderLight),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.stadium_outlined, color: BentoColors.bentoSlate500, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              match.stadium,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: BentoColors.bentoSlate500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: Icon(
                            match.reminderEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            color: match.reminderEnabled
                                ? BentoColors.soccerGreen
                                : BentoColors.bentoSlate500,
                            size: 18,
                          ),
                          onPressed: () => provider.toggleReminder(match.id),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: Icon(
                            match.isFavorite ? Icons.star : Icons.star_border,
                            color: match.isFavorite ? BentoColors.worldCupGold : BentoColors.bentoSlate500,
                            size: 18,
                          ),
                          onPressed: () => provider.toggleFavorite(match.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularFlag(String flag) {
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(1.5), // Gold border ring thickness
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFE07D), // Gold highlight
            Color(0xFFB08C23), // Deep gold shadow
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          flag,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class MatchCardInline extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const MatchCardInline({
    Key? key,
    required this.match,
    required this.onTap,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: BentoColors.softWhite, // Crema premium
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BentoColors.bentoBorderLight, width: 1.5), // Gold border
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildCircularFlag(match.homeFlag),
                  const SizedBox(width: 8),
                  Text(
                    match.homeTeam,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: BentoColors.deepSlate,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 100, // Slightly wider to hold the vertical lines nicely
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '|',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: BentoColors.bentoBorderLight.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  match.status == 'próximo'
                      ? Text(
                          match.localTime,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: BentoColors.deepSlate,
                          ),
                        )
                      : Text(
                          '${match.homeScore} - ${match.awayScore}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: match.status == 'en vivo' ? Colors.red : BentoColors.deepSlate,
                          ),
                        ),
                  const SizedBox(width: 8),
                  Text(
                    '|',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: BentoColors.bentoBorderLight.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    match.awayTeam,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: BentoColors.deepSlate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCircularFlag(match.awayFlag),
                ],
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${match.date} | ${match.stadium}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                color: BentoColors.bentoSlate500,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            match.isFavorite ? Icons.star : Icons.star_border,
            color: match.isFavorite ? BentoColors.worldCupGold : BentoColors.bentoSlate500,
            size: 20,
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }

  Widget _buildCircularFlag(String flag) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(1.5), // Gold border ring thickness
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFE07D), // Gold highlight
            Color(0xFFB08C23), // Deep gold shadow
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          flag,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
