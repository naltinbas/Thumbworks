import 'package:flutter/material.dart';

import '../whistle/levels.dart';
import '../whistle/play.dart';
import 'moorview.dart';

/// The game's mark: the four calls whistled the shepherd's way, every
/// tune spoken for.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The marking the mark draws, real and checked: the shepherd's way
  /// with the four calls.
  static Play get fourCalls => Play.standing(Levels.at(1), Play.aimFor(Levels.at(1))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MoorView(
          play: fourCalls,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
