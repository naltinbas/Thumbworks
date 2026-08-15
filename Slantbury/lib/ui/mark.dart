import 'package:flutter/material.dart';

import '../pieces/levels.dart';
import '../pieces/play.dart';
import 'frameview.dart';

/// The game's mark: the four pieces laid in the thirteen-by-five, the
/// sliver bare along the slant.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The laying the mark draws, real and checked: the sweep's first
  /// laying of the frame.
  static Play get frame => Play.standing(Levels.at(1), Play.aimFor(Levels.at(1))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FrameView(
          play: frame,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
