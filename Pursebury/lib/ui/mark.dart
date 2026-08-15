import 'package:flutter/material.dart';

import '../duel/levels.dart';
import '../duel/play.dart';
import 'duelview.dart';

/// The game's mark: the chain of six coins to one against the coin,
/// sagging under the fair line and stopping short of a half.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: six coins to one with
  /// the coin against Ash, 63/127, the nearest the hopeless ask comes.
  static Play get sag => Play.standing(Levels.at(4), 6, 1, 0);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DuelView(
          play: sag,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
