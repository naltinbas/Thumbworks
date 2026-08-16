import 'package:flutter/material.dart';

import '../odd/levels.dart';
import '../odd/play.dart';
import 'oddview.dart';

/// The game's mark: the square of seven, 1 + 3 + 5 + 7 + 9 + 11 + 13
/// laid as seven L-shaped bands of dots.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The run the mark draws, real and checked: seven odd numbers from
  /// 1, 49, The Square of Seven's aim.
  static Play get seven => Play.standing(Levels.at(0), 1, 7);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: OddView(
          play: seven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
