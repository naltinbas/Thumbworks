import 'package:flutter/material.dart';

import '../lane/levels.dart';
import '../lane/play.dart';
import 'laneview.dart';

/// The game's mark: the field with the medians meeting.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The gates the mark draws, real and checked: the medians, meeting
  /// at (4, 4), The Medians' own aim.
  static Play get medians => Play.standing(Levels.at(0), 6, 6, 6);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LaneView(
          play: medians,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
