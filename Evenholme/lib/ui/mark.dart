import 'package:flutter/material.dart';

import '../split/levels.dart';
import '../split/play.dart';
import 'splitview.dart';

/// The game's mark: twenty on the slate, split as 3 + 17.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The pick the mark draws, real and checked: 3 of twenty, its partner
  /// 17, The Twenty's own aim.
  static Play get three => Play.standing(Levels.at(0), 3);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SplitView(
          play: three,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
