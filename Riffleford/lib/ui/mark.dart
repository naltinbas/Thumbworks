import 'package:flutter/material.dart';

import '../deck/play.dart';
import '../deck/riffles.dart';
import 'deckview.dart';

/// The game's mark: the odd cut riffled sloppily, three from the
/// first pile then the rest, every pair mixed all the same.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The riffle the mark draws, real and checked.
  static Play get oddCut => Play.standing(Riffles.at(0), 'ABBABABB');

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DeckView(
          play: oddCut,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
