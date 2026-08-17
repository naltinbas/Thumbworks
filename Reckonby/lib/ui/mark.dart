import 'package:flutter/material.dart';

import '../count/levels.dart';
import '../count/play.dart';
import 'wheelview.dart';

/// The game's mark: every wheel at its top, which is the highest the
/// house reads and one short of rolling over.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The reading the mark draws, real and checked: 719.
  static Play get wheels =>
      Play.standing(Levels.at(3), const [1, 2, 3, 4, 5]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WheelView(
          play: wheels,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
