import 'package:flutter/material.dart';

import '../coffer/levels.dart';
import '../coffer/play.dart';
import 'cofferview.dart';

/// The game's mark: Bertrand's three coffers, gold and gold, gold and
/// silver, silver and silver.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The laying the mark draws, real and checked: Bertrand's own, one of
  /// The Two Thirds' twelve, chance 2/3.
  static Play get bertrand => Play.standing(Levels.at(0), const [true, true, true, false, false, false]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CofferView(
          play: bertrand,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
