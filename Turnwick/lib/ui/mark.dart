import 'package:flutter/material.dart';

import '../pack/levels.dart';
import '../pack/play.dart';
import 'packview.dart';

/// The game's mark: all four up, the pattern as asked.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The pack the mark draws, real and checked: turn, cut, cut, turn.
  static Play get allUp => Play.of(Levels.at(3)).turn.cut.cut.turn;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PackView(
          play: allUp,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
