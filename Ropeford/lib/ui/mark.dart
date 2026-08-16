import 'package:flutter/material.dart';

import '../ford/levels.dart';
import '../ford/play.dart';
import 'fordview.dart';

/// The game's mark: the crossing part way over, standing on stone 23
/// with the rope out to 46.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The crossing the mark draws, real and checked: the greedy one,
  /// five hops in, its rope reaching 46 with 29, 31, 37, 41 and 43
  /// under it.
  static Play get crossing =>
      Play.standing(Levels.at(0), const [2, 3, 5, 7, 13, 23]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FordView(
          play: crossing,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
