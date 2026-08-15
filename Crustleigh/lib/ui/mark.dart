import 'package:flutter/material.dart';

import '../show/levels.dart';
import '../show/play.dart';
import 'showview.dart';

/// The game's mark: three pies round a ring, the majority running round.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The show the mark draws, real and checked: the sweep's first ring,
  /// the three turnings of apple bramble cherry.
  static Play get ring => Play.standing(Levels.at(0), Play.aimFor(Levels.at(0))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ShowView(
          play: ring,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
