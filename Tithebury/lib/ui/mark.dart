import 'package:flutter/material.dart';

import '../tithe/levels.dart';
import '../tithe/play.dart';
import 'titheview.dart';

/// The game's mark: twenty-eight, its divisors laid end to end coming
/// out exactly even.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The number the mark draws, real and checked: 28, perfect, The
  /// Perfect's own aim.
  static Play get perfect => Play.standing(Levels.at(0), 28);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TitheView(
          play: perfect,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
