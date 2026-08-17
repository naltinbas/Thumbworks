import 'package:flutter/material.dart';

import '../hoop/levels.dart';
import '../hoop/play.dart';
import 'hoopview.dart';

/// The game's mark: two dark stones and four pale laid so the lamps
/// come to exactly five, which is the floor and the fewest they can be.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The board the mark draws, real and checked. Dark stones in holes 0
  /// and 1, pale stones in 0, 1, 2 and 3: two runs at the same step.
  static Play get board => Play.laid(Levels.at(3), 0x03, 0x0F);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HoopView(
          play: board,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
