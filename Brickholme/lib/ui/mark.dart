import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import 'yardview.dart';

/// The game's mark: the eight yard paved round its drain, twenty-one
/// bricks.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The paving the mark draws, real and checked: the walk's paving of
  /// the eight yard.
  static Play get eightYard => Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: eightYard,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
