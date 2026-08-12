import 'package:flutter/material.dart';

import '../debt/play.dart';
import '../debt/villages.dart';
import 'fenview.dart';

/// The game's mark: The Charity as it opens, two houses in debt,
/// two pounds clear, and every class of spread on the village
/// known to settle.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The village the mark draws, real and checked.
  static Play get charity => Play.of(Villages.at(2));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FenView(
          play: charity,
          pointing: -1,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
