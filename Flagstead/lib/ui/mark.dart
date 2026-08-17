import 'package:flutter/material.dart';

import '../hall/levels.dart';
import '../hall/play.dart';
import 'hallview.dart';

/// The game's mark: the six by eight hall with the peg three paces
/// along and four up, every post five paces off.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked: one of the two in
  /// the whole sweep with the peg inside the hall and every distance a
  /// whole number.
  static Play get within => Play.standing(Levels.at(3), 6, 8, 3, 4);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HallView(
          play: within,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
