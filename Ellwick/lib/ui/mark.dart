import 'package:flutter/material.dart';

import '../rung/levels.dart';
import '../rung/play.dart';
import 'rungview.dart';

/// The game's mark: the square, its diagonal, and the ladder up it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark stands at, real and checked: the top rung of
  /// the dials, 70 and 99, one over.
  static Play get top => Play.standing(Levels.at(0), 70, 99);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RungView(
          play: top,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
