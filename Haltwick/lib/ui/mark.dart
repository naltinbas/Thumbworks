import 'package:flutter/material.dart';

import '../wait/levels.dart';
import '../wait/play.dart';
import 'waitview.dart';

/// The game's mark: the waits of the gaps 10, 10 and 40 as a sawtooth,
/// the average in gold across it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The timetable the mark draws, real and checked: gaps 10, 10 and 40,
  /// average wait 14 1/2 minutes, one of The Fourteen and a Half's three.
  static Play get bunched => Play.standing(Levels.at(1), 10, 10);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WaitView(
          play: bunched,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
