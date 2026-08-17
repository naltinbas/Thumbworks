import 'package:flutter/material.dart';

import '../shape/levels.dart';
import '../shape/play.dart';
import 'shapeview.dart';

/// The game's mark: the staircase with the most fillings of all, 4, 2,
/// 1, 1, whose hooks multiply to 448 and leave 90.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The staircase the mark draws, real and checked.
  static Play get shape => Play.standing(Levels.at(1), const [4, 2, 1, 1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ShapeView(
          play: shape,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
