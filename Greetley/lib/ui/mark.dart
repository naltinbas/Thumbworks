import 'package:flutter/material.dart';

import '../shake/lawns.dart';
import '../shake/play.dart';
import 'lawnview.dart';

/// The game's mark: a lawn of five with four hands up, the even
/// guest quiet at the top of the ring.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The lawn the mark draws, found by the sweep and checked.
  static Play get fourOdd {
    final fete = Lawns.at(2);
    final play = Play.of(fete);
    return Play.standing(fete, play.rules.busyLawn(fete.asked)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LawnView(
          play: fourOdd,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
