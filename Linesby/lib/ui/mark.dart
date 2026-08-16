import 'package:flutter/material.dart';

import '../line/levels.dart';
import '../line/play.dart';
import 'lineview.dart';

/// The game's mark: the triangle (0, 0), (4, 0), (1, 3) with its three
/// centres in a flat line through it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The triangle the mark draws, real and checked: The Level Line's
  /// aim, its centres G (5/3, 1), O (2, 1) and H (1, 1) at one height.
  static Play get line => Play.standing(Levels.at(1), const [(0, 0), (4, 0), (1, 3)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LineView(
          play: line,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
