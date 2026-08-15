import 'package:flutter/material.dart';

import '../stall/levels.dart';
import '../stall/play.dart';
import 'stallview.dart';

/// The game's mark: three doors, the pick on the first, the host's goat
/// behind the third.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The stall the mark draws, real and checked: three doors, one
  /// opened, switching, two in three.
  static Play get three => Play.standing(Levels.at(0), 3, 1, true);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StallView(
          play: three,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
