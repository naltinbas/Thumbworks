import 'package:flutter/material.dart';

import '../board/play.dart';
import '../board/plots.dart';
import '../board/rules.dart';
import 'boardview.dart';

/// The game's mark: five pins with a fence of three and the lone
/// frame inside, built as the theorem builds it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked.
  static Play get loneFrame => Play.standing(
      Plots.at(2), const [(0, 0), (4, 0), (2, 4), (1, 1), (3, 1)]);

  static bool get marksHold {
    final pins = loneFrame.pins;
    return !Rules.anyThreeInLine(pins) &&
        Rules.fence(pins).length == 3 &&
        Rules.frames(pins).length == 1;
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BoardView(
          play: loneFrame,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
