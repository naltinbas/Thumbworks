import 'package:flutter/material.dart';

import '../ways/levels.dart';
import '../ways/play.dart';
import 'wayview.dart';

/// The game's mark: the house pointed so that every place can be
/// reached from every other.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The orientation the mark draws, real and checked: one of the six
  /// that leave the house one-way throughout.
  static Play get round => Play.standing(
        Levels.at(2),
        const [false, false, false, false, false, false],
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WayView(
          play: round,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
