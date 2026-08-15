import 'package:flutter/material.dart';

import '../quilt/levels.dart';
import '../quilt/play.dart';
import 'quiltview.dart';

/// The game's mark: the two-by-six quilt sewn out, every house patch
/// answered across the middle.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The quilt the mark draws, real and checked: the house's three
  /// patches each answered by its mirror, and the house left with
  /// nothing.
  static Play get mirrored => Play.standing(Levels.at(0), const [
        ((0, 1), false),
        ((10, 11), true),
        ((2, 3), false),
        ((8, 9), true),
        ((4, 5), false),
        ((6, 7), true),
      ]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: QuiltView(
          play: mirrored,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
