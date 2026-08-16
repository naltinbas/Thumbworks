import 'package:flutter/material.dart';

import '../trio/levels.dart';
import '../trio/play.dart';
import '../trio/rules.dart';
import 'trioview.dart';

/// The game's mark: the twenty trios laid out, the even hand's ten in
/// gold.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The family the mark draws, real and checked: ABC, ABD, ACE, ADF,
  /// AEF, BCF, BDE, BEF, CDE, CDF, every two sharing a friend and every
  /// friend in five, one of The Even Hand's twelve.
  static Play get even => Play.standing(Levels.at(2), Rules.familyOf('ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE, CDF'));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TrioView(
          play: even,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
