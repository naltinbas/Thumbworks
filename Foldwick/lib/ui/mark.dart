import 'package:flutter/material.dart';

import '../plank/crossings.dart';
import '../plank/play.dart';
import 'plankview.dart';

/// The game's mark: three and three mid-crossing, the plank reading
/// sheep goat sheep goat sheep goat with the empty pen at the end,
/// the beasts fully interleaved.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The plank the mark draws, real and checked: reachable, on the
  /// way across.
  static Play get midway => Play.standing(Crossings.at(3), 'GSGSGS_');

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PlankView(
          play: midway,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
