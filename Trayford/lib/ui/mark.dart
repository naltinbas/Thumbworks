import 'package:flutter/material.dart';

import '../count/play.dart';
import '../count/trays.dart';
import 'trayview.dart';

/// The game's mark: Sun Tzu's own count, twenty-three eggs, two
/// over by threes, three by fives, two by sevens.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The count the mark draws, real and checked.
  static Play get oldCount => Play.standing(Trays.at(1), 23);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TrayView(
          play: oldCount,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
