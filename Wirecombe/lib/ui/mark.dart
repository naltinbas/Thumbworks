import 'package:flutter/material.dart';

import '../wire/combes.dart';
import '../wire/play.dart';
import 'combeview.dart';

/// The game's mark: the star, one cottage holding every line and
/// four windows lit at the lane's ends.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The run the mark draws, found by the sweep and checked.
  static Play get star {
    final combe = Combes.at(3);
    final play = Play.of(combe);
    return Play.standing(combe, play.rules.run(combe.ends)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CombeView(
          play: star,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
