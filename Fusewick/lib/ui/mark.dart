import 'package:flutter/material.dart';

import '../fuse/levels.dart';
import '../fuse/play.dart';
import 'fuseview.dart';

/// The game's mark: the forty-five at its half-hour, one fuse burnt out
/// and the other lit at both ends with half an hour left.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The moment the mark draws, real and checked: thirty minutes in.
  static Play get fortyFive => Play.standing(Levels.at(1), 120, const [0, 120], const [(true, true), (true, true)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FuseView(
          play: fortyFive,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
