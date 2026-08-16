import 'package:flutter/material.dart';

import '../kith/levels.dart';
import '../kith/play.dart';
import '../kith/rules.dart';
import 'kithview.dart';

/// The game's mark: the star, Ann friends with all five, the widest gap
/// there is.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The plan the mark draws, real and checked: Ann friends with Bess,
  /// Cal, Dot, Ed and Fay and nobody else with anybody, people averaging
  /// 1 2/3 friends and the friends named 3, the gap 1 1/3.
  static Play get star => Play.standing(Levels.at(2), Rules.planOf('Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay'));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: KithView(
          play: star,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
