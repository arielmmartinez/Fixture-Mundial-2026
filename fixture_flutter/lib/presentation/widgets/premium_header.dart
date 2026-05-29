import 'package:flutter/material';
import '../../core/theme/bento_theme.dart';

class PremiumHeader extends StatelessWidget {
  final String subtitle;

  const PremiumHeader({
    Key? key,
    this.subtitle = 'FASE DE GRUPOS',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 180 + statusBarHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/argentina_trophy_banner.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.9, 1.0],
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Title: "Mundial 2026"
            const Text(
              'Mundial 2026',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 34,
                fontWeight: FontWeight.black,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                letterSpacing: -1,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                  Shadow(
                    color: BentoColors.worldCupGold,
                    offset: Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Badge: "FASE DE GRUPOS"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF047857), // Deep emerald
                    BentoColors.soccerGreen, // Neon Turquesa
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: BentoColors.electricGreen.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BentoColors.electricGreen.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.black,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
