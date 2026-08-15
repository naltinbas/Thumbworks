import 'package:flutter/material.dart';

import '../cellar/levels.dart';
import '../cellar/play.dart';
import 'cellarview.dart';

/// The game's mark: the eight casks, the coin found in three.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The search the mark draws, real and checked: the eight cut in the
  /// middle three times, the cellarman keeping the right, the coin in
  /// the last cask.
  static Play get eight => Play.of(Levels.at(0)).cut(4).cut(2).cut(1);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CellarView(
          play: eight,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
