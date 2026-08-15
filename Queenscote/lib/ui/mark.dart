import 'package:flutter/material.dart';

import '../watch/levels.dart';
import '../watch/play.dart';
import 'watchview.dart';

/// The game's mark: five queens watching the whole chessboard.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked: The Chessboard's aim,
  /// the picking's first watching set of five.
  static Play get five => Play.standing(Levels.at(2), Levels.at(2).aim!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WatchView(
          play: five,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
