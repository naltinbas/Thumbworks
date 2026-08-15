import 'package:flutter/material.dart';

import '../pebble/askings.dart';
import '../pebble/play.dart';
import 'rowsview.dart';

/// The game's mark: sixty picked, the smallest heap with twelve
/// even rows, its divisor grid below.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The heap the mark draws, real and checked.
  static Play get sixty => Play.standing(Askings.at(3), 60);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RowsView(
          play: sixty,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
