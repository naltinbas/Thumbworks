import 'package:flutter/material.dart';

import '../knights/levels.dart';
import '../knights/play.dart';
import 'boardview.dart';

/// The game's mark: the four by four seated, eight knights on the
/// corners' colour.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: one colour of the
  /// four by four.
  static Play get fourByFour => Play.standing(Levels.at(1), Play.aimFor(Levels.at(1)));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BoardView(
          play: fourByFour,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
