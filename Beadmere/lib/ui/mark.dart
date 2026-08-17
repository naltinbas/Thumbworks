import 'package:flutter/material.dart';

import '../strip/levels.dart';
import '../strip/play.dart';
import 'stripview.dart';

/// The game's mark: the strip of eleven that repeats every five and
/// every eight without repeating every one.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The strip the mark draws, real and checked: one of the two that
  /// land the fourth ask, and the longest strip there is with those two
  /// repeats and not their divisor.
  static Play get fibonacci =>
      Play.standing(Levels.at(3), const [0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StripView(
          play: fibonacci,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
