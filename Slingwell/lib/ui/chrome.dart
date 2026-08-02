import 'package:flutter/widgets.dart';

import '../best_run.dart';
import 'palette.dart';

/// How the best run is said, in both places that say it.
///
/// The seed goes with the score wherever it is shown: it is the difference
/// between a number and a run the player can go back to.
String bestLine(BestRun best) {
  if (!best.hasRun) return 'no best yet';
  final seed = best.seed;
  return seed == null
      ? 'best ${best.score} wells'
      : 'best ${best.score} wells on seed $seed';
}

/// The small spaced-out words that say what a number is.
const labelStyle = TextStyle(
  color: Palette.rungInk,
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 2.6,
);

/// A line of quiet text under a card's headline.
const noteStyle = TextStyle(
  color: Palette.rungInk,
  fontSize: 14,
  height: 1.4,
);

/// A number and what it counts.
///
/// The figures are drawn on a fixed width, because a height counting up in
/// metres changes several times a second and proportional digits make
/// everything beside it shuffle sideways while it does.
class Readout extends StatelessWidget {
  const Readout({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.size = 44,
    this.align = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final Color color;
  final double size;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: size,
              height: 1.0,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: labelStyle),
        ],
      );
}

/// Darkens the run behind a card enough to read words over it without hiding
/// it. The world carrying on underneath is half of what makes a title screen
/// look like a game rather than a menu, so the top of the screen stays nearly
/// clear and only the band the words sit in goes dark.
class Scrim extends StatelessWidget {
  const Scrim({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Palette.skyTop.withValues(alpha: 0.25),
              Palette.skyTop.withValues(alpha: 0.86),
              Palette.skyTop.withValues(alpha: 0.96),
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
        child: child,
      );
}
