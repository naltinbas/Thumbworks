import 'package:flutter/material.dart';

import '../poll/levels.dart';
import '../poll/play.dart';
import 'pollview.dart';

/// The game's mark: the count of five to three that turns twice.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The order the mark draws, real and checked: The Two Turns' aim, the
  /// sweep's first order of five to three where the lead changes hands
  /// twice.
  static Play get turns => Play.standing(Levels.at(2), Levels.at(2).aim!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PollView(
          play: turns,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
