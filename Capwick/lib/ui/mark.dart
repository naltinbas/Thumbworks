import 'package:flutter/material.dart';

import '../line/levels.dart';
import '../line/play.dart';
import 'lineview.dart';

/// The game's mark: the line of five called down by the plan, four
/// saved and the first man alone wrong.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The line the mark draws, real and checked: the plan's calls on the
  /// dealt five, black, black, black, white, black.
  static Play get five => Play.standing(Levels.at(2), const [true, true, true, false, true]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LineView(
          play: five,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
