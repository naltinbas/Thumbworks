import 'package:flutter/material.dart';

import '../marsh/marshes.dart';
import '../marsh/play.dart';
import '../marsh/rules.dart';
import 'marshview.dart';

/// The game's mark: the one frame, a needle setting where five
/// posts hold exactly one four standing true.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The setting the mark draws, found by the sweep and checked.
  static Play get oneFrame {
    final marsh = Marshes.at(2);
    return Play.standing(
        marsh, Rules.setting(marsh.posts, marsh.asked)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MarshView(
          play: oneFrame,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
