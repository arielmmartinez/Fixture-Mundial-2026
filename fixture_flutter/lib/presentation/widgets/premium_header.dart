import 'package:flutter/material.dart';
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
            // Space occupied by the baked-in header elements
            const SizedBox(height: 108),
          ],
        ),
      ),
    );
  }
}
