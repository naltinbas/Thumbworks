import 'package:flutter/material.dart';

import '../plait/levels.dart';
import '../plait/play.dart';
import 'plaitview.dart';

/// The game's mark: the trefoil, the first knot there is, painted in all
/// three dyes with every crossing sitting right.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The plait the mark draws, real and checked.
  static Play get plait => const Play.painted(Levels.short, [0, 1, 2]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PlaitView(
          play: plait,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
