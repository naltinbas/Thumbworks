import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import 'boardview.dart';

/// The game's mark: the six yard watched, four watchmen one in from
/// each corner.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The posting the mark draws, real and checked: the six yard's one
  /// posting of four.
  static Play get sixYard => Play.standing(Levels.at(2), Play.aimFor(Levels.at(2)));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BoardView(
          play: sixYard,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
