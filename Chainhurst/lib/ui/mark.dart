import 'package:flutter/material.dart';

import '../chain/fields.dart';
import '../chain/play.dart';
import 'chainview.dart';

/// The game's mark: the fewest of five landed, four stones in a
/// row and one stood off, four bare chains of gold round one
/// laden chain of moss.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The placing the mark draws, real and checked.
  static Play get fewest => Play.standing(
        Fields.at(3),
        const [(0, 2), (1, 2), (2, 2), (3, 2), (2, 0)],
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ChainView(
          play: fewest,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
