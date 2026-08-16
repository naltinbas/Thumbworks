import 'package:flutter/material.dart';

import '../heap/levels.dart';
import '../heap/play.dart';
import 'heapview.dart';

/// The game's mark: three heaps of stones, 3, 1 and 1, the five's three.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The heap the mark stands for, real and checked: 3 + 1 + 1 makes
  /// five from three, which two heaps never do.
  static Play get five => Play.standing(Levels.at(4), const [3, 1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HeapView(
          play: five,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
