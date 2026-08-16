import 'package:flutter/material.dart';

import '../root/levels.dart';
import '../root/play.dart';
import 'rootview.dart';

/// The game's mark: the walk of 3 round the seven-hour clock, home on
/// the sixth step with every hour but 0 touched.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: The Seven's aim, the
  /// base 3 on the seven-hour clock.
  static Play get seven => Play.standing(Levels.at(0), 7, 3);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RootView(
          play: seven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
