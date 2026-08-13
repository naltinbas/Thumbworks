import 'package:flutter/material.dart';

import '../window/houses.dart';
import '../window/play.dart';
import 'windowview.dart';

/// The game's mark: the classic seven-turn dialling, nought,
/// one, three, seven, its whole road written to the dark.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The dialled house the mark draws, real and checked.
  static Play get classic =>
      Play.standing(Houses.at(2), const [0, 1, 3, 7]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WindowView(
          play: classic,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
