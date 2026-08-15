import 'package:flutter/material.dart';

import '../village/levels.dart';
import '../village/play.dart';
import 'villageview.dart';

/// The game's mark: the village with the fever one in a hundred and the
/// test ninety-nine in a hundred both ways, the flagged half ill.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The village the mark draws, real and checked: one in a hundred,
  /// ninety-nine in a hundred, one in a hundred.
  static Play get hundred => Play.standing(Levels.at(0), 5, 2, 2);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: VillageView(
          play: hundred,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
