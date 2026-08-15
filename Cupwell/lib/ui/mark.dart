import 'package:flutter/material.dart';

import '../tray/levels.dart';
import '../tray/play.dart';
import 'trayview.dart';

/// The game's mark: three cups on the tray, one down between two up.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The tray the mark draws, real and checked: the one of three, the
  /// middle cup down, which twos never right.
  static Play get oneOfThree => Play.standing(Levels.at(4), 0x2, 0);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TrayView(
          play: oneOfThree,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
