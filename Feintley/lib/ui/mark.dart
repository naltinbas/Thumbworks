import 'package:flutter/material.dart';

import '../feint/levels.dart';
import '../feint/play.dart';
import 'feintview.dart';

/// The game's mark: 341 on base two, the first liar, its squares lit
/// and its landing one.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: 341, which is 11
  /// times 31, passing Fermat's test on base two and lying about it.
  static Play get liar => Play.standing(Levels.at(1), 341, 2);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FeintView(
          play: liar,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
