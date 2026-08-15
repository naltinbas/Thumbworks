import 'package:flutter/material.dart';

import '../comb/levels.dart';
import '../comb/play.dart';
import 'combview.dart';

/// The game's mark: Adams' comb filled, every line thirty-eight.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The filling the mark draws, real and checked: Adams' comb on the
  /// whole comb.
  static Play get adams => Play.standing(Levels.at(3), Levels.adams);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CombView(
          play: adams,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
