import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import 'yardview.dart';

/// The game's mark: the swapped pair, home but for the 7 and the 8.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The yard the mark draws, real and checked: Loyd's swapped pair, the
  /// one arrangement here the shunts never reach.
  static Play get swapped => Play.of(Levels.at(4));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: swapped,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
