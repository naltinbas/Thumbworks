import 'package:flutter/material.dart';

import '../cut/levels.dart';
import '../cut/play.dart';
import 'cutview.dart';

/// The game's mark: the triangle cut by the line through (6, 0) and
/// (0, 4), the middle of AB and two more cuts, one of them outside.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The line the mark draws, real and checked: through (6, 0) and
  /// (0, 4), AF:FB 1, BD:DC -1/2 and CE:EA 2, one of The Middle Cut's
  /// ninety.
  static Play get middle => Play.standing(Levels.at(1), const [(6, 0), (0, 4)]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CutView(
          play: middle,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
