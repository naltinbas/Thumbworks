import 'package:flutter/material.dart';

import '../skein/levels.dart';
import '../skein/play.dart';
import '../skein/rules.dart';
import 'skeinview.dart';

/// The game's mark: the ring that runs through all five greens, where
/// every lane takes the same share, 4/5, and five of those make four.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The village the mark draws, real and checked: the lanes 1 to 2,
  /// 2 to 3, 3 to 4, 4 to 5 and 1 to 5.
  static Play get village =>
      Play.standing(Levels.at(1), Rules.laid(const [0, 3, 4, 7, 9]));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SkeinView(
          play: village,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
