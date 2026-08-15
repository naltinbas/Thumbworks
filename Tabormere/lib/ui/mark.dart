import 'package:flutter/material.dart';

import '../drum/levels.dart';
import '../drum/play.dart';
import 'drumview.dart';

/// The game's mark: the tresillo, three hits in eight steps.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The pattern the mark draws, real and checked: x..x..x., the
  /// tresillo, one of the eight even patterns of three in eight.
  static Play get tresillo => Play.standing(Levels.at(0), const [0, 3, 6]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DrumView(
          play: tresillo,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
