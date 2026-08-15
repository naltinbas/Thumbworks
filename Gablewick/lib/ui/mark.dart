import 'package:flutter/material.dart';

import '../gable/levels.dart';
import '../gable/play.dart';
import 'gableview.dart';

/// The game's mark: the 13-14-15 gable, area 84.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The sides the mark draws, real and checked: 13, 14, 15, whole area
  /// 84, The Uneven's own aim.
  static Play get gable => Play.standing(Levels.at(3), 13, 15, 14);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GableView(
          play: gable,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
