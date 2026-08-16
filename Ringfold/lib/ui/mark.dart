import 'package:flutter/material.dart';

import '../period/levels.dart';
import '../period/play.dart';
import 'periodview.dart';

/// The game's mark: the Fibonacci numbers walked round the five-hour
/// clock, twenty steps and home.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The clock the mark draws, real and checked: five hours, period
  /// twenty, The Twenty's aim.
  static Play get five => Play.standing(Levels.at(1), 5);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PeriodView(
          play: five,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
