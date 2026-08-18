import 'package:flutter/material.dart';

import '../yoke/levels.dart';
import '../yoke/play.dart';
import 'yokeview.dart';

/// The game's mark: the team in matching order, which pulls hardest and
/// has no pair crossed.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The team the mark draws, real and checked.
  static Play get team => Play.yoked(Levels.at(3), const [0, 1, 2, 3, 4]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YokeView(
          play: team,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
