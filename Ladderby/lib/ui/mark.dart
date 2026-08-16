import 'package:flutter/material.dart';

import '../join/levels.dart';
import '../join/play.dart';
import 'joinview.dart';

/// The game's mark: the hexagon of bottom pegs 0, 3, 6 and top pegs 1,
/// 4, 7, its three crossings on the middle rung.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The hexagon the mark draws, real and checked: bottom 0, 3, 6 with
  /// top 1, 4, 7, the bottom three shifted along by one, crossing at
  /// (2, 3), (7/2, 3) and (5, 3), one of The Middle Rung's 196.
  static Play get middle => Play.standing(Levels.at(1), const [0, 3, 6], const [1, 4, 7]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: JoinView(
          play: middle,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
