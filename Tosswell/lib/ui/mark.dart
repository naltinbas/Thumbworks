import 'package:flutter/material.dart';

import '../toss/levels.dart';
import '../toss/play.dart';
import '../toss/rules.dart';
import 'tossview.dart';

/// The game's mark: the rule that walks away a shilling up after the
/// first toss and again after the third, which is ahead on 22 of the
/// 32 runs and still averages nothing.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The rule the mark draws, real and checked.
  static Play get rule => Play.standing(
      Levels.at(2), {Rules.mark((1, 1)), Rules.mark((3, 1))});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TossView(
          play: rule,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
