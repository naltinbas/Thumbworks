import 'package:flutter/material.dart';

import '../road/levels.dart';
import '../road/play.dart';
import 'roadview.dart';

/// The game's mark: forty hundred drivers with the shortcut open, all
/// of them going top, across and bottom.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: forty hundred, the
  /// shortcut open, everyone taking 80 minutes, The Eighty's aim.
  static Play get eighty => Play.standing(Levels.at(1), 40, true);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RoadView(
          play: eighty,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
