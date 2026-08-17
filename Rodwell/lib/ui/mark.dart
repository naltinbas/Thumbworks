import 'package:flutter/material.dart';

import '../rod/levels.dart';
import '../rod/play.dart';
import 'rodview.dart';

/// The game's mark: the rod of twelve cut into four threes, the one
/// cutting of the 2,048 that reaches 81.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The cutting the mark draws, real and checked.
  static Play get threes => Play.standing(Levels.at(2), const {2, 5, 8});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RodView(
          play: threes,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
