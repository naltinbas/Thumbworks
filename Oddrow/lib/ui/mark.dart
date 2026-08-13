import 'package:flutter/material.dart';

import '../row/askings.dart';
import '../row/play.dart';
import 'rowview.dart';

/// The game's mark: the wall wound to the full row, the whole
/// Sierpinski lace above a line of sixteen golden odds.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The wound wall the mark draws, real and checked.
  static Play get fullRow => Play.standing(Askings.at(3), 15);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RowView(
          play: fullRow,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
