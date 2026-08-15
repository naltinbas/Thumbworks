import 'package:flutter/material.dart';

import '../deck/levels.dart';
import '../deck/play.dart';
import 'deckview.dart';

/// The game's mark: five pirates paid eight, nought, one, nought, one,
/// and the ayes in.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The plan the mark draws, real and checked: the best plan for five,
  /// voted.
  static Play get five => Play.standing(Levels.at(3), Play.aimFor(Levels.at(3)));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DeckView(
          play: five,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
