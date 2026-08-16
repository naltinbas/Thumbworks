import 'package:flutter/material.dart';

import '../step/levels.dart';
import '../step/play.dart';
import 'stepview.dart';

/// The game's mark: seven halvings down the corridor, 127/128 covered,
/// the wall still ahead.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The run the mark draws, real and checked: seven halvings, The
  /// Hundredth's aim.
  static Play get seven => Play.standing(Levels.at(0), 0, 7);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StepView(
          play: seven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
