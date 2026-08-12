import 'package:flutter/material.dart';

import '../fold/folds.dart';
import '../fold/play.dart';
import 'foldview.dart';

/// The game's mark: a zigzag folding, crowns of one and three
/// alternating round the hexagon with its three ears lit.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The folding the mark draws, found by the sweep and checked.
  static Play get zigzag {
    final fold = Folds.at(3);
    final play = Play.of(fold);
    return Play.standing(fold, play.rules.fencing(fold.lands)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FoldView(
          play: zigzag,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
