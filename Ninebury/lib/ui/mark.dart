import 'package:flutter/material.dart';

import '../nine/levels.dart';
import '../nine/play.dart';
import 'nineview.dart';

/// The game's mark: 738 walked round the nine-hour dial, seven, three
/// and eight, home at nine.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The number the mark draws, real and checked: 738, three different
  /// digits adding to 18 and so to 9, one of The Nine's 84.
  static Play get nine => Play.standing(Levels.at(0), 738);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: NineView(
          play: nine,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
