import 'package:flutter/material.dart';

import '../sum/moors.dart';
import '../sum/play.dart';
import 'moorview.dart';

/// The game's mark: one of the eighteen thirteens, Schur's wall
/// painted right up to the brick.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The painting the mark draws, found by the sweep and checked.
  static Play get thirteen {
    final moor = Moors.at(3);
    final play = Play.of(moor);
    return Play.standing(moor, play.rules.painting()!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MoorView(
          play: thirteen,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
