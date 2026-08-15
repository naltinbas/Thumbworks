import 'package:flutter/material.dart';

import '../mere/lightings.dart';
import '../mere/play.dart';
import 'mereview.dart';

/// The game's mark: the boat, five lanterns lying still, each
/// wearing its two or three.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The lighting the mark draws, real and checked.
  static Play get boat => Play.standing(Lightings.at(1), const {(2, 1), (1, 2), (3, 2), (2, 3), (3, 3)});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MereView(
          play: boat,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
