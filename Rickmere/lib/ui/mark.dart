import 'package:flutter/material.dart';

import '../rick/levels.dart';
import '../rick/play.dart';
import 'rickview.dart';

/// The game's mark: a field with a square corner, its three ricks
/// raised outward, and the even ring of markers over them.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The field the mark draws, real and checked.
  static Play get field =>
      Play.standing(Levels.at(0), const [(0, 0), (3, 0), (0, 4)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RickView(
          play: field,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
