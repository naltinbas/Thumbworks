import 'package:flutter/material.dart';

import '../wall/levels.dart';
import '../wall/play.dart';
import 'wallview.dart';

/// The game's mark: Moron's wall of nine, hung.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The hanging the mark draws, real and checked: the search's first
  /// hanging of the nine on thirty-two by thirty-three.
  static Play get nine => Play.standing(Levels.at(1), Play.aimFor(Levels.at(1))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WallView(
          play: nine,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
