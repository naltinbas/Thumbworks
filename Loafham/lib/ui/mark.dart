import 'package:flutter/material.dart';

import '../loaf/loaves.dart';
import '../loaf/play.dart';
import 'loafview.dart';

/// The game's mark: four fifths cut as a half, a quarter and a
/// twentieth, the greedy cut of the Rhind papyrus.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The cut share the mark draws, real and checked.
  static Play get fourFifths => Play.standing(Loaves.at(1), const [2, 4, 20]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LoafView(
          play: fourFifths,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
