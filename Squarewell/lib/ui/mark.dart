import 'package:flutter/material.dart';

import '../square/levels.dart';
import '../square/play.dart';
import 'squareview.dart';

/// The game's mark: the seven-hour clock with its three squares lit and
/// the base 3, with its opposite 4, landing on 2.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: The Two of Seven's
  /// aim, base 3 on the seven-hour clock, squaring to 2.
  static Play get seven => Play.standing(Levels.at(0), 7, 3);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SquareView(
          play: seven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
