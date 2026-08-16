import 'package:flutter/material.dart';

import '../kiss/levels.dart';
import '../kiss/play.dart';
import 'kissview.dart';

/// The game's mark: the bends 2, 2 and 3, the bubble of bend 15 in the
/// gap and the unit bubble round the outside.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: 2, 2 and 3, fourths
  /// 15 and -1, the gasket Descartes and Soddy both drew.
  static Play get gasket => Play.standing(Levels.at(0), const [2, 2, 3]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: KissView(
          play: gasket,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
