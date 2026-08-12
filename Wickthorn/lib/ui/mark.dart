import 'package:flutter/material.dart';

import '../rope/greens.dart';
import '../rope/play.dart';
import 'ropeview.dart';

/// The game's mark: the seven ropes closed, seven lanterns in a
/// ring with every pair sharing exactly one rope.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The closing the mark draws, real and checked.
  static Play get closing => Play.standing(
        Greens.at(3),
        const [
          (0, 1, 2), (0, 3, 4), (0, 5, 6), (1, 3, 5),
          (1, 4, 6), (2, 3, 6), (2, 4, 5),
        ],
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RopeView(
          play: closing,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
