import 'package:flutter/material.dart';

import '../scale/levels.dart';
import '../scale/play.dart';
import '../scale/rules.dart';
import 'scaleview.dart';

/// The game's mark: twenty balanced, all four weights on the scale.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked: 27 and 3 across, 9
  /// and 1 beside the load of twenty.
  static Play get twenty =>
      Play.standing(Levels.at(1), const [Side.withLoad, Side.against, Side.withLoad, Side.against]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ScaleView(
          play: twenty,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
