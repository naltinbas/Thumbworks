import 'package:flutter/material.dart';

import '../lamp/levels.dart';
import '../lamp/play.dart';
import 'lampview.dart';

/// The game's mark: a message in the code with four lamps lit, which
/// the reader can mend whichever lamp goes out.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The message the mark draws, real and checked: lamps 3, 4, 5 and 6.
  static Play get lamps =>
      Play.standing(Levels.at(1), const [0, 0, 1, 1, 1, 1, 0, 0]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LampView(
          play: lamps,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
