import 'package:flutter/material.dart';

import '../ring/levels.dart';
import '../ring/play.dart';
import 'ringview.dart';

/// The game's mark: a bid pushed above the worth in the sealed ring,
/// so the strip climbs while the rivals bid low and drops below the
/// line as soon as they bid past what the beast is worth.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: a beast worth 8, a
  /// bid of 12, a rival at 10.
  static Play get ring => Play.standing(Levels.at(0), 8, 12, 10);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RingView(
          play: ring,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
