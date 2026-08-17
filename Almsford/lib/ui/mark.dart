import 'package:flutter/material.dart';

import '../alms/levels.dart';
import '../alms/play.dart';
import 'almsview.dart';

/// The game's mark: the staircase, four bins climbing and one empty,
/// which is the shape a share-out most often lands in.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The arrangement the mark draws, real and checked: 0, 1, 2, 3, 4.
  static Play get bins =>
      Play.standing(Levels.at(2), const [0, 1, 2, 3, 4]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: AlmsView(
          play: bins,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
