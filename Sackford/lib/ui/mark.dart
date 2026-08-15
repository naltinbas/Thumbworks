import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import 'yardview.dart';

/// The game's mark: three carts full to the brim.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The yard the mark draws, real and checked: the three carts loaded
  /// six and four, five and five, four and four and two.
  static Play get three => Play.standing(Levels.at(1), Play.aimFor(Levels.at(1))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: three,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
