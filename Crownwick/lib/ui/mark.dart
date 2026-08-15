import 'package:flutter/material.dart';

import '../kings/levels.dart';
import '../kings/play.dart';
import 'boardview.dart';

/// The game's mark: the five by five seated, nine kings on the even
/// squares.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: the even squares of
  /// the five by five.
  static Play get fiveByFive => Play.standing(Levels.at(2), Play.aimFor(Levels.at(2)));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BoardView(
          play: fiveByFive,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
