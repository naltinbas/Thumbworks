import 'package:flutter/material.dart';

import '../wheel/cordings.dart';
import '../wheel/play.dart';
import 'wheelview.dart';

/// The game's mark: a square corner on the rim, looking across at a
/// diameter in gold.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The cording the mark draws, real and checked.
  static Play get rightCorner => Play.standing(Cordings.at(0), const [(-5, 0), (5, 0), (3, 4)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WheelView(
          play: rightCorner,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
