import 'package:flutter/material.dart';

import '../slice/cakes.dart';
import '../slice/play.dart';
import 'sliceview.dart';

/// The game's mark: six candles cutting thirty-one, the
/// doubling broken on the cake itself.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed pick the mark draws, real and checked.
  static Play get thirtyOne =>
      Play.standing(Cakes.at(2), const [0, 2, 4, 5, 8, 9]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SliceView(
          play: thirtyOne,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
