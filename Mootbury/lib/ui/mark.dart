import 'package:flutter/material.dart';

import '../moot/levels.dart';
import '../moot/play.dart';
import 'mootview.dart';

/// The game's mark: the moot of ten among six, six and two, and the seat
/// Cote loses at eleven.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The moot the mark draws, real and checked: ten seats, 4, 4, 2, and
  /// eleven giving 5, 5, 1.
  static Play get ten => Play.standing(Levels.at(0), 10);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MootView(
          play: ten,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
