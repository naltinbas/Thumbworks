import 'package:flutter/material.dart';

import '../turn/levels.dart';
import '../turn/play.dart';
import 'turnview.dart';

/// The game's mark: a seventh, 0.142857 under its bar, and the six
/// remainders walked round the seven-hour ring.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The fraction the mark draws, real and checked: 1 over 7, period
  /// six, The Six's aim.
  static Play get seventh => Play.standing(Levels.at(0), 7, 1);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TurnView(
          play: seventh,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
