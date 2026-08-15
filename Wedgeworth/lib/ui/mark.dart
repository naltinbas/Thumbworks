import 'package:flutter/material.dart';

import '../wedge/levels.dart';
import '../wedge/play.dart';
import 'wedgeview.dart';

/// The game's mark: five triangles round a point, the icosahedron's
/// corner, with its sixty degrees to spare.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The corner the mark draws, real and checked: five triangles.
  static Play get icosahedron => Play.standing(Levels.at(3), 3, 5);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WedgeView(
          play: icosahedron,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
