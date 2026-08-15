import 'package:flutter/material.dart';

import '../hex/levels.dart';
import '../hex/play.dart';
import 'hexview.dart';

/// The game's mark: the two-box tiled, cubes stacked in it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The tiling the mark draws, real and checked: the sweep's first
  /// tiling of the two-box.
  static Play get twoBox => Play.standing(Levels.at(2), Play.aimFor(Levels.at(2))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HexView(
          play: twoBox,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
