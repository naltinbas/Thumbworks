import 'package:flutter/material.dart';

import '../square/levels.dart';
import '../square/play.dart';
import 'squareview.dart';

/// The game's mark: the square of pegs (1, 1), (3, 1), (3, 3), (1, 3),
/// its four squares built outward, and the two joins crossing at the
/// middle.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The four the mark draws, real and checked: (1, 1), (3, 1), (3, 3),
  /// (1, 3), the centres at (2, 0), (4, 2), (2, 4) and (0, 2), the joins
  /// four long and crossing at (2, 2).
  static Play get square => Play.standing(Levels.at(1), const [(1, 1), (3, 1), (3, 3), (1, 3)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SquareView(
          play: square,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
