import 'package:flutter/material.dart';

import '../train/levels.dart';
import '../train/play.dart';
import 'trainview.dart';

/// The game's mark: the ring of four, turning.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The train the mark draws, real and checked: the square of four
  /// gears of one round the crank.
  static Play get ring => Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!.sublist(1));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TrainView(
          play: ring,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
