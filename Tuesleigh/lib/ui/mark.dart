import 'package:flutter/material.dart';

import '../family/levels.dart';
import '../family/play.dart';
import 'familyview.dart';

/// The game's mark: the fourteen-by-fourteen grid of families under
/// seven tags, the twenty-seven with a Tuesday boy lit and the thirteen
/// of two boys gold.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The tag count the mark draws, real and checked: seven, 13/27, The
  /// Tuesday Boy's aim.
  static Play get tuesday => Play.standing(Levels.at(2), 7);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FamilyView(
          play: tuesday,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
