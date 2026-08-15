import 'package:flutter/material.dart';

import '../deck/levels.dart';
import '../deck/play.dart';
import 'deckview.dart';

/// The game's mark: the pair of hearts laid, the 7 hidden behind the 2
/// and three cards telling five.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The layout the mark draws, real and checked: 7H hidden, 2H KC 5D
  /// 9S laid.
  static Play get hearts => Play.standing(Levels.at(0), 32, const [27, 12, 17, 47]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DeckView(
          play: hearts,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
