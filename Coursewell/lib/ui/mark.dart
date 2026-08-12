import 'package:flutter/material.dart';

import '../course/play.dart';
import '../course/yards.dart';
import 'courseview.dart';

/// The game's mark: the sound course itself, five by six
/// bricked with no seam, one of the six layings there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed laying the mark draws, real and checked.
  static Play get sound {
    final yard = Yards.at(2);
    return Play.standing(
      yard,
      Play.of(yard).rules.laying(0)!,
    );
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CourseView(
          play: sound,
          showCounts: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
