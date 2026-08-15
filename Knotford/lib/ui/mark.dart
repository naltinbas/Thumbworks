import 'package:flutter/material.dart';

import '../rope/play.dart';
import '../rope/ropes.dart';
import 'ropeview.dart';

/// The game's mark: the twelve-knot rope round three pegs, three
/// gaps, four and five, the corner square.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The marking the mark draws, real and checked: pegs at knots 3 and
  /// 7 of twelve.
  static Play get twelve => Play.standing(Ropes.at(0), const [3, 7]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RopeView(
          play: twelve,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
