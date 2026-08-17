import 'package:flutter/material.dart';

import '../lane/levels.dart';
import '../lane/play.dart';
import 'laneview.dart';

/// The game's mark: the five houses with the pump at the middle one.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked: spot 5, where the
  /// walking of the five houses comes to 15, the least there is.
  static Play get middle => Play.standing(Levels.at(0), 5);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LaneView(
          play: middle,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
