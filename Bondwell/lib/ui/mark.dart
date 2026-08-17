import 'package:flutter/material.dart';

import '../bond/levels.dart';
import '../bond/play.dart';
import 'purseview.dart';

/// The game's mark: the Talmud's three hundred zuz row, 6, 12 and 18
/// coins, with all three scales level.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The division the mark draws, real and checked: the one division of
  /// the 703 that hangs every scale level.
  static Play get large => Play.standing(Levels.at(2), const [6, 12, 18]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PurseView(
          play: large,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
