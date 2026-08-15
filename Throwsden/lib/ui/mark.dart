import 'package:flutter/material.dart';

import '../fair/levels.dart';
import '../fair/play.dart';
import 'yardview.dart';

/// The game's mark: the four lined up, Ash, Dane, Cole and Bram, each
/// having thrown the next.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The line the mark draws, real and checked: the walk's first line
  /// of The Four.
  static Play get four => Play.standing(Levels.at(0), const [0, 3, 2, 1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: four,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
