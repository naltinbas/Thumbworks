import 'package:flutter/material.dart';

import '../board/levels.dart';
import '../board/play.dart';
import 'boardview.dart';

/// The game's mark: six bishops on the four-by-four, none on another's
/// diagonal.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: the sweep's first
  /// peaceful six.
  static Play get six => Play.standing(Levels.at(1), const [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BoardView(
          play: six,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
