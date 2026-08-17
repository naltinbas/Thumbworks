import 'package:flutter/material.dart';

import '../beat/levels.dart';
import '../beat/play.dart';
import '../beat/rules.dart';
import 'beatview.dart';

/// The game's mark: the five throws laid so they juggle, drawn as the
/// flights they make, the pile of them the balls in the air.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The laying the mark draws, real and checked.
  static Play get laying =>
      Play.laying(Levels.at(1), Rules.ways(Levels.at(1).rack).first);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BeatView(
          play: laying,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
