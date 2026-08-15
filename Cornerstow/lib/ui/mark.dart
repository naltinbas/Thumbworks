import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import '../yard/rules.dart';
import 'yardview.dart';

/// The game's mark: Nicomachus's own paving of the six-by-six, band by
/// band round the corner.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The paving the mark draws, real and checked: the gnomons of three.
  static Play get six => Play.standing(Levels.at(1), Rules.gnomons(3));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: six,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
