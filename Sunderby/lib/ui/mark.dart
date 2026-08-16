import 'package:flutter/material.dart';

import '../part/levels.dart';
import '../part/play.dart';
import 'partview.dart';

/// The game's mark: the dots of 5 + 2 + 1, eight sundered into
/// different parts.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The partition the mark draws, real and checked: 5 + 2 + 1, all
  /// different and three parts, The Different's own aim.
  static Play get dots => Play.standing(Levels.at(0), const [5, 2, 1]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PartView(
          play: dots,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
