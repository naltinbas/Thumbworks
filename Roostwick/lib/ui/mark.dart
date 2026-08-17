import 'package:flutter/material.dart';

import '../roost/levels.dart';
import '../roost/play.dart';
import 'roostview.dart';

/// The game's mark: the hub settled, six birds in six hollows, with the
/// doubled tether between A and B turned one way.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The wood the mark draws, real and checked.
  static Play get wood => Play.sitting(Levels.at(3), 62);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RoostView(
          play: wood,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
