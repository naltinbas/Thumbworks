import 'package:flutter/material.dart';

import '../road/levels.dart';
import '../road/play.dart';
import '../road/rules.dart';
import 'roadview.dart';

/// The game's mark: the threes-and-threes plan, every village joined to
/// the three across from it, and its round trip.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The plan the mark draws, real and checked: AD, AE, AF, BD, BE, BF,
  /// CD, CE, CF, three roads at every village, one of The Nine Roads'
  /// seventy, its round trip A D B E C F.
  static Play get threes => Play.standing(Levels.at(2), Rules.planOf('AD, AE, AF, BD, BE, BF, CD, CE, CF'));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RoadView(
          play: threes,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
