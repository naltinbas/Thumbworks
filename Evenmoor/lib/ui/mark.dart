import 'package:flutter/material.dart';

import '../moor/peggings.dart';
import '../moor/play.dart';
import 'moorview.dart';

/// The game's mark: five pegs on the moor, one to each kind and a
/// fifth forced to share, its post landed green.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked: exactly one post
  /// landed.
  static Play get five => Play.standing(Peggings.at(2), const [(0, 0), (3, 0), (0, 3), (3, 3), (4, 4)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MoorView(
          play: five,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
