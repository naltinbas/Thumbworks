import 'package:flutter/material.dart';

import '../foot/levels.dart';
import '../foot/play.dart';
import 'footview.dart';

/// The game's mark: the triangle (5, 0), (-4, 3), (-3, -4) on the rim,
/// the point (0, 5) above, and its three feet in a line.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: the triangle (5, 0),
  /// (-4, 3), (-3, -4) with the rim point (0, 5), its feet at (-21/5,
  /// 22/5), (3, -1) and (-1, 2), in a line.
  static Play get simson => Play.standing(Levels.at(3), const [(5, 0), (-4, 3), (-3, -4)], (0, 5));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FootView(
          play: simson,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
