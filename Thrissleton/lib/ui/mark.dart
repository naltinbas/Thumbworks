import 'package:flutter/material.dart';

import '../third/hands.dart';
import '../third/play.dart';
import 'thirdview.dart';

/// The game's mark: the perfect ten, five stones of one
/// remainder and all ten triples washed green at once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed hand the mark draws, real and checked.
  static Play get perfectTen =>
      Play.standing(Hands.at(2), const [3, 6, 3, 6, 3]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ThirdView(
          play: perfectTen,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
