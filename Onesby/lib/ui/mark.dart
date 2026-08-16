import 'package:flutter/material.dart';

import '../ones/levels.dart';
import '../ones/play.dart';
import 'onesview.dart';

/// The game's mark: seven ones, 127, prime, the row that makes 8,128.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The exponent the mark draws, real and checked: 7, the row 127,
  /// prime both ways, The Perfect Eight Thousand's aim.
  static Play get seven => Play.standing(Levels.at(2), 7);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: OnesView(
          play: seven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
