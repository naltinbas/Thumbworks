import 'package:flutter/material.dart';

import '../watch/meres.dart';
import '../watch/play.dart';
import 'watchview.dart';

/// The game's mark: the pinch itself, three watches meeting in
/// a single gold hour.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed dialling the mark draws, real and checked: the
  /// watches at 0, 2 and 3 share hour three alone.
  static Play get pinch =>
      Play.standing(Meres.at(1), const [0, 2, 3]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WatchView(
          play: pinch,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
