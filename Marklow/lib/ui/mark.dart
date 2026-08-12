import 'package:flutter/material.dart';

import '../mark/lows.dart';
import '../mark/play.dart';
import 'lowview.dart';

/// The game's mark: the square graced, four gaps running one to
/// four round the ring.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The numbering the mark draws, found by the sweep and
  /// checked.
  static Play get square {
    final low = Lows.at(2);
    final play = Play.of(low);
    return Play.standing(low, play.rules.numbering()!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LowView(
          play: square,
          showWords: true,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
