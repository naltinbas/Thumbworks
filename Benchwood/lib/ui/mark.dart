import 'package:flutter/material.dart';

import '../bench/levels.dart';
import '../bench/play.dart';
import 'benchview.dart';

/// The game's mark: Belady's own card on a bench of three, part way
/// through the seven walks.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked: two carries into
  /// the card, made the way Belady's rule makes them.
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
