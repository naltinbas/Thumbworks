import 'package:flutter/material.dart';

import '../glass/levels.dart';
import '../glass/play.dart';
import 'glassview.dart';

/// The game's mark: the two glasses after the pouring, a band of each in
/// the other.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: ten of each and a
  /// spoon of five, 10/3 of a unit each way.
  static Play get glasses => Play.standing(Levels.at(4), 10, 10, 5);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GlassView(
          play: glasses,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
