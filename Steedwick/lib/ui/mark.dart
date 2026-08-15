import 'package:flutter/material.dart';

import '../paddock/errands.dart';
import '../paddock/play.dart';
import 'paddockview.dart';

/// The game's mark: the paddock at home, the knight's ring drawn
/// through the stalls, pale steeds at the top and dark below.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked: the colour swap
  /// done, each steed across from its own corner.
  static Play get swapped => Play.standing(Errands.at(3), const [8, 6, 2, 0]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PaddockView(
          play: swapped,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
