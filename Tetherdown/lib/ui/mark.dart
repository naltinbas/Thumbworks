import 'package:flutter/material.dart';

import '../down/downs.dart';
import '../down/play.dart';
import 'downview.dart';

/// The game's mark: the nine, six posts split into two pastures
/// of three with every crossing roped and not a knot anywhere.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The tethering the mark draws, found by the sweep and checked.
  static Play get nine {
    final down = Downs.at(3);
    final play = Play.of(down);
    return Play.standing(down, play.rules.tethering(down.asked)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DownView(
          play: nine,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
