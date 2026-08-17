import 'package:flutter/material.dart';

import '../plot/levels.dart';
import '../plot/play.dart';
import '../plot/rules.dart';
import 'plotview.dart';

/// The game's mark: the field cut into three plots, which always comes
/// out 3, 6 and 9 half acres and never 6, 6 and 6.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The cut the mark draws, real and checked.
  static Play get cut => Play.cut(Levels.at(1), Rules.cutsOf(3).first);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PlotView(
          play: cut,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
