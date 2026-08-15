import 'package:flutter/material.dart';

import '../hall/levels.dart';
import '../hall/play.dart';
import 'hallview.dart';

/// The game's mark: the cube seated, eight guests across from every
/// quarreller.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The seating the mark draws, real and checked: the walk's seating of
  /// the cube.
  static Play get cube => Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HallView(
          play: cube,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
