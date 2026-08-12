import 'package:flutter/material.dart';

import '../hill/hills.dart';
import '../hill/play.dart';
import 'hillview.dart';

/// The game's mark: the eleven, the one planting in 729 that
/// fills the side-five hill with eleven patches.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The planting the mark draws, found by the sweep and checked.
  static Play get eleven {
    final hill = Hills.at(3);
    final play = Play.of(hill);
    return Play.standing(hill, play.rules.planting(11)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HillView(
          play: eleven,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
