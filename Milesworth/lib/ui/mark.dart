import 'package:flutter/material.dart';

import '../lane/levels.dart';
import '../lane/play.dart';
import 'laneview.dart';

/// The game's mark: the lane of fifteen with 4, 5, 6 marked, and the
/// coins that make fifteen.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The marking the mark draws, real and checked: 4 to 6 on the
  /// fifteen.
  static Play get fifteen => Play.standing(Levels.at(0), const [4, 6]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LaneView(
          play: fifteen,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
