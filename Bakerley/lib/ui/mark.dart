import 'package:flutter/material.dart';

import '../tray/levels.dart';
import '../tray/play.dart';
import 'trayview.dart';

/// The game's mark: the pinwheel, four tees on the four-by-four.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The tray the mark draws, real and checked: the search's first
  /// filling of the four-by-four by four tees.
  static Play get pinwheel => Play.standing(Levels.at(0), Play.aimFor(Levels.at(0))!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TrayView(
          play: pinwheel,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
