import 'package:flutter/material.dart';

import '../stack/levels.dart';
import '../stack/play.dart';
import 'stackview.dart';

/// The game's mark: four books over the desk edge, the top one a whole
/// book out and a twenty-fourth past it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The stack the mark draws, real and checked: the harmonic four,
  /// half, a quarter, a sixth and an eighth.
  static Play get four => Play.standing(Levels.at(2), const [12, 6, 4, 3]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StackView(
          play: four,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
