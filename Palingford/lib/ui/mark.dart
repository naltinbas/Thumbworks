import 'package:flutter/material.dart';

import '../paling/levels.dart';
import '../paling/play.dart';
import 'palingview.dart';

/// The game's mark: a fence of ten with its longest climb marked, standing
/// in four falling runs of four, three, two and one that step up as they go.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The fence the mark draws, real and checked: the one the first ask
  /// points at, with the longest climb and the longest drop both four, which
  /// is the shortest either can be made on a fence of ten.
  static Play get fence =>
      Play.built(Levels.at(0), Levels.at(0).aim);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PalingView(
          play: fence,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
