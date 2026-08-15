import 'package:flutter/material.dart';

import '../roll/levels.dart';
import '../roll/play.dart';
import 'rollview.dart';

/// The game's mark: the equal coins, the roller's mark drawing the heart.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: The Twice's aim, a
  /// hoop of three and a roller of three round the outside.
  static Play get heart => Play.standing(Levels.at(0), 3, 3, false);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RollView(
          play: heart,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
