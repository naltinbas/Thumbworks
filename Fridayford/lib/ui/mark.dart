import 'package:flutter/material.dart';

import '../almanac/levels.dart';
import '../almanac/play.dart';
import 'yearview.dart';

/// The game's mark: a common year beginning on a Thursday, three
/// Fridays the thirteenth ringed.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The year the mark draws, real and checked: Thursday, common, three
  /// Fridays.
  static Play get thursday => Play.standing(Levels.at(2), 3, false);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YearView(
          play: thursday,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
