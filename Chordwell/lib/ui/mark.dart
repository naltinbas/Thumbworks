import 'package:flutter/material.dart';

import '../chord/levels.dart';
import '../chord/play.dart';
import 'wheelview.dart';

/// The game's mark: the chord from (3, 4) to (3, -4) crossed by the
/// horizontal diameter at (3, 0), four times four and two times eight.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The crossing the mark draws, real and checked: 4 times 4 is 16 and
  /// 2 times 8 is 16, at (3, 0), one of The Halved's sixty-four.
  static Play get sixteen => Play.standing(Levels.at(3), const [1, 5, 3, 9]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WheelView(
          play: sixteen,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
