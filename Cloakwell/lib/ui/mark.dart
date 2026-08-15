import 'package:flutter/material.dart';

import '../rail/levels.dart';
import '../rail/play.dart';
import 'railview.dart';

/// The game's mark: the reverse of four, every pair strung askew.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The rail the mark draws, real and checked: 4, 3, 2, 1 as it opens,
  /// six pairs out of order.
  static Play get reverse => Play.of(Levels.at(1));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RailView(
          play: reverse,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
