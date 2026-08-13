import 'package:flutter/material.dart';

import '../clink/feasts.dart';
import '../clink/play.dart';
import 'clinkview.dart';

/// The game's mark: the four counts standing, one shy of all
/// different, every badge its own tint but two.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed feast the mark draws, real and checked: guest
  /// nought clinks everyone, one clinks two more, two clinks
  /// one more, and the counts run 4, 3, 3, 2, 1... checked in
  /// the mark test rather than trusted.
  static Play get fourCounts => Play.standing(
        Feasts.at(2),
        const [true, true, true, true, true, true, false, false, false, false],
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ClinkView(
          play: fourCounts,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
