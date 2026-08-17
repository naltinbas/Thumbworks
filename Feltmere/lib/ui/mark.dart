import 'package:flutter/material.dart';

import '../hat/levels.dart';
import '../hat/play.dart';
import 'hatview.dart';

/// The game's mark: the agreement that wins six hattings of the eight,
/// speak when the two hats you see match and name the other colour.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The agreement the mark draws, real and checked: one of the four
  /// that win six of the eight hattings.
  static Play get six => Play.standing(Levels.at(3), const [
        [1, 2, 2, 0],
        [1, 2, 2, 0],
        [1, 2, 2, 0],
      ]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HatView(
          play: six,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
