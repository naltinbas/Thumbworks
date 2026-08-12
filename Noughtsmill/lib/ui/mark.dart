import 'package:flutter/material.dart';

import '../mill/grinds.dart';
import '../mill/play.dart';
import 'millview.dart';

/// The game's mark: the mill wound to a hundred, twenty-four
/// noughts strung below.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The winding the mark draws, checked like any other.
  static Play get hundred => Play.standing(Grinds.at(3), 100);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MillView(
          play: hundred,
          showWords: false,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
