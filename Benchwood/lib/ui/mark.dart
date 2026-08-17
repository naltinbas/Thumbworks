import 'package:flutter/material.dart';

import '../bench/levels.dart';
import '../bench/play.dart';
import 'benchview.dart';

/// The game's mark: Belady's own card on a bench of three, two carries
/// and five walks in.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and reachable by two taps: two
  /// carries into the card, the first slot both times, which is not the
  /// slot Belady's rule would carry back.
  static Play get partWay => Play.standing(Levels.at(2), const [0, 0]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BenchView(
          play: partWay,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
