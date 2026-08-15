import 'package:flutter/material.dart';

import '../field/levels.dart';
import '../field/play.dart';
import 'fieldview.dart';

/// The game's mark: the three-by-three field walked over its stile,
/// gate to mill.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The walk the mark draws, real and checked: the walk's first
  /// route over the stile at (1, 2).
  static Play get stile => Play.standing(
      Levels.at(0), const [(0, 0), (1, 0), (1, 1), (1, 2), (2, 2), (3, 2), (3, 3)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FieldView(
          play: stile,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
