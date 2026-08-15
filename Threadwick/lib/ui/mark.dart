import 'package:flutter/material.dart';

import '../star/levels.dart';
import '../star/play.dart';
import 'starview.dart';

/// The game's mark: the star of David, threaded in its two strokes.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: six nails, skip two,
  /// two triangles, the very thing The Star of David asks for in one
  /// stroke and cannot have.
  static Play get david => Play.standing(Levels.at(4), 6, 2);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StarView(
          play: david,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
