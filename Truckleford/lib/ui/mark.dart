import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import 'yardview.dart';

/// The game's mark: a yard part way through a run, three wagons on the
/// siding, one already out and two still on the line.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The yard the mark draws, real and reachable: shunt 1, shunt 2,
  /// shunt 3, then roll 4 straight out.
  static Play get yard => Play.standing(
      Levels.at(1), const [5, 6], const [1, 2, 3], const [4]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: yard,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
