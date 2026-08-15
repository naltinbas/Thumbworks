import 'package:flutter/material.dart';

import '../green/levels.dart';
import '../green/play.dart';
import 'greenview.dart';

/// The game's mark: the four hamlets, each laned to each, laid clear.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The green the mark draws, real and checked: the sweep's first clear
  /// placing of the four hamlets, each laned to each.
  static Play get four => Play.standing(Levels.at(0), Play.aimFor(Levels.at(0))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GreenView(
          play: four,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
