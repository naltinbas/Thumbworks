import 'package:flutter/material.dart';

import '../pair/levels.dart';
import '../pair/play.dart';
import 'pairview.dart';

/// The game's mark: S's 17 and P's 52 on their cards, and the pair
/// beneath, 4 and 13.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The pair the mark draws, real and checked: 4 and 13, the one pair
  /// of the 2,352 for which all four things said hold.
  static Play get answer => Play.standing(Levels.at(3), 4, 13);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PairView(
          play: answer,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
