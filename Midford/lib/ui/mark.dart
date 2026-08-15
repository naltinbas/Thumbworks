import 'package:flutter/material.dart';

import '../peg/cordings.dart';
import '../peg/play.dart';
import 'pegview.dart';

/// The game's mark: a kite of pegs whose midpoint figure is a
/// rectangle, the diagonals crossing square.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The four pegs the mark draws, real and checked.
  static Play get kite => Play.standing(Cordings.at(0), const [(2, 0), (4, 2), (2, 4), (0, 2)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PegView(
          play: kite,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
