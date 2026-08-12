import 'package:flutter/material.dart';

import '../pane/play.dart';
import '../pane/sashes.dart';
import 'paneview.dart';

/// The game's mark: the nine landed, the big sash at its limit
/// with every row-pair spent exactly once and not a window
/// framed.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked.
  static Play get nine => Play.standing(
        Sashes.at(3),
        const [
          (0, 0), (0, 1), (0, 2),
          (1, 0), (1, 3),
          (2, 1), (2, 3),
          (3, 2), (3, 3),
        ],
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PaneView(
          play: nine,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
