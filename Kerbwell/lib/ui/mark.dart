import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/yards.dart';
import 'yardview.dart';

/// The game's mark: eight slabs in a kerb of twelve, the three by
/// three less a corner.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked.
  static Play get eight => Play.standing(Yards.at(2), const {
        (1, 1), (2, 1), (3, 1),
        (1, 2), (2, 2), (3, 2),
        (1, 3), (2, 3),
      });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: eight,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
