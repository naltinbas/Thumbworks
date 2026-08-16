import 'package:flutter/material.dart';

import '../sight/levels.dart';
import '../sight/play.dart';
import 'sightview.dart';

/// The game's mark: the orchard, its trees in sight and hidden, and the
/// line of sight to the tree at (3, 7).
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The tree the mark draws, real and checked: (3, 7), in sight in the
  /// far region, file three and row seven sharing no factor.
  static Play get sight => Play.standing(Levels.at(0), (3, 7));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SightView(
          play: sight,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
