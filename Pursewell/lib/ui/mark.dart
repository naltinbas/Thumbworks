import 'package:flutter/material.dart';

import '../purse/play.dart';
import '../purse/purses.dart';
import 'purseview.dart';

/// The game's mark: the forty-seven paid, two far coins with the
/// one between them unspent.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The payment the mark draws, the sweep's own and checked.
  static Play get fortySeven =>
      Play.standing(Purses.at(3), const [13, 34]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PurseView(
          play: fortySeven,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
