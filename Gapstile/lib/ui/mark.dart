import 'package:flutter/material.dart';

import '../gap/play.dart';
import '../gap/stiles.dart';
import 'gapview.dart';

/// The game's mark: the needle of the fence, seven pegs at four
/// over eleven, the one dial to twelfths (with its mirror) that
/// shows all three gap lengths at once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The landed needle the mark draws, real and checked.
  static Play get needle => Play.standing(Stiles.at(3), 4, 11);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GapView(
          play: needle,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
