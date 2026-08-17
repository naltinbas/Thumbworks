import 'package:flutter/material.dart';

import '../isle/levels.dart';
import '../isle/play.dart';
import 'isleview.dart';

/// The game's mark: the three villagers of the second ask, named the
/// one way that holds.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The naming the mark draws, real and checked: Birch alone a knight,
  /// the one naming of the eight that holds every telling.
  static Play get named =>
      Play.standing(Levels.at(1), const [false, true, false]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: IsleView(
          play: named,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
