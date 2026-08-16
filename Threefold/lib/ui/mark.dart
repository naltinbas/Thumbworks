import 'package:flutter/material.dart';

import '../green/levels.dart';
import '../green/play.dart';
import 'greenview.dart';

/// The game's mark: the green with the walker at 2, 4 and 6 and the
/// three distances drawn.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The point the mark draws, real and checked: 2, 4 and 6, The
  /// Doubles' own aim, the three adding to twelve.
  static Play get walker => Play.standing(Levels.at(3), (2, 4, 6));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GreenView(
          play: walker,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
