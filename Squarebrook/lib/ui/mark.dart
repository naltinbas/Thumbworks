import 'package:flutter/material.dart';

import '../stones/levels.dart';
import '../stones/play.dart';
import 'stonesview.dart';

/// The game's mark: ninety-nine made of three squares, one, forty-nine
/// and forty-nine.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The making the mark draws, real and checked: the sweep's first
  /// making of ninety-nine.
  static Play get ninetyNine => Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StonesView(
          play: ninetyNine,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
