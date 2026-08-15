import 'package:flutter/material.dart';

import '../ring/levels.dart';
import '../ring/play.dart';
import 'ringview.dart';

/// The game's mark: six pennies round a penny, touching all round.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: equal coins of two,
  /// six round with nothing to spare, The Six's own landing.
  static Play get pennies => Play.standing(Levels.at(1), 2, 2);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RingView(
          play: pennies,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
