import 'package:flutter/material.dart';

import '../thread/play.dart';
import '../thread/rows.dart';
import 'threadview.dart';

/// The game's mark: one of the six eights, a full row with no
/// ladder anywhere in it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The threading the mark draws, found by the sweep and checked.
  static Play get eight {
    final row = Rows.at(2);
    final play = Play.of(row);
    return Play.standing(row, play.rules.threading(const [])!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ThreadView(
          play: eight,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
