import 'package:flutter/material.dart';

import '../peck/flocks.dart';
import '../peck/play.dart';
import '../peck/rules.dart';
import 'peckview.dart';

/// The game's mark: the full court itself, the round pecking of
/// five where every chicken pecks the next two and every one
/// wears a crown.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The crowned pecking the mark draws, real and checked.
  static Play get court {
    final rules = Rules(5);
    return Play.standing(Flocks.at(3), [
      for (final (a, b) in rules.pairs) !(b - a == 1 || b - a == 2),
    ]);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PeckView(
          play: court,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
