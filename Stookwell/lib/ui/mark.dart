import 'package:flutter/material.dart';

import '../stook/levels.dart';
import '../stook/play.dart';
import 'stookview.dart';

/// The game's mark: seven sheaves in stooks of 4, 2 and 1, all apart.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked: 4, 2 and 1, which
  /// is where Glaisher's turn sends seven ones.
  static Play get seven => Play.standing(Levels.at(0), const [4, 2, 1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StookView(
          play: seven,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
