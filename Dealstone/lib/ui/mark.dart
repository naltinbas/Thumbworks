import 'package:flutter/material.dart';

import '../deal/handfuls.dart';
import '../deal/play.dart';
import 'dealview.dart';

/// The game's mark: the stair of ten standing whole, four,
/// three, two, one, the hand the deal pays straight back.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed hand the mark draws, real and checked.
  static Play get stair =>
      Play.standing(Handfuls.at(3), const [4, 3, 2, 1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DealView(
          play: stair,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
