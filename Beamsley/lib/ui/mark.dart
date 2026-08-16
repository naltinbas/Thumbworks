import 'package:flutter/material.dart';

import '../shadow/levels.dart';
import '../shadow/play.dart';
import 'shadowview.dart';

/// The game's mark: the triangle (2, -2), (0, 2), (2, 1) cast 2, -2 and
/// -1, its shadow triangle and the axis through the three meetings.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: the meetings at
  /// (3, -4), (-6, 5) and (2, -3), all three on the line x + y = -1,
  /// and all three on peg places, one of The Whole Meets' 1,248.
  static Play get cast => Play.standing(Levels.at(0), const [(2, -2), (0, 2), (2, 1)], const [2, -2, -1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ShadowView(
          play: cast,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
