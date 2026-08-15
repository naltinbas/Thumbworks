import 'package:flutter/material.dart';

import '../garden/levels.dart';
import '../garden/play.dart';
import 'gardenview.dart';

/// The game's mark: the wide reversal, Ash at half and Birch at seven
/// in ten.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: Ash ten and twenty,
  /// Birch fifty and ten.
  static Play get wide => Play.standing(Levels.at(2), const [10, 20, 50, 10]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GardenView(
          play: wide,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
