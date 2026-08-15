import 'package:flutter/material.dart';

import '../coil/levels.dart';
import '../coil/play.dart';
import 'coilview.dart';

/// The game's mark: the coil with the twelve fifths stacked and dropped
/// to the comma.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: The Circle's aim,
  /// twelve fifths up and seven octaves down.
  static Play get comma => Play.standing(Levels.at(3), 12, -7);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CoilView(
          play: comma,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
