import 'package:flutter/material.dart';

import '../school/levels.dart';
import '../school/play.dart';
import 'schoolview.dart';

/// The game's mark: Kirkman's week walked whole, every pair met once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The week the mark draws, real and checked: the affine plane's
  /// columns and two slants placed after the rows given.
  static Play get week => Play.standing(Levels.at(3), const [
        0, 3, 6, 1, 4, 7, 2, 5, 8, //
        0, 4, 8, 1, 5, 6, 2, 3, 7, //
        0, 5, 7, 1, 3, 8, 2, 4, 6, //
      ]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SchoolView(
          play: week,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
