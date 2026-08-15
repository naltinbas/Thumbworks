import 'package:flutter/material.dart';

import '../kite/levels.dart';
import '../kite/play.dart';
import 'kiteview.dart';

/// The game's mark: the kite of order three, slated.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The slating the mark draws, real and checked: the order three, the
  /// sweep's thirty-second slating of its sixty-four, a mix of across
  /// and down.
  static Play get slated => Play.standing(Levels.at(3), Levels.at(3).slatings[31]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: KiteView(
          play: slated,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
