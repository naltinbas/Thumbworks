import 'package:flutter/material.dart';

import '../rack/pantries.dart';
import '../rack/play.dart';
import '../rack/rules.dart';
import 'rackview.dart';

/// The game's mark: the dozen racked home by chain height,
/// Mirsky's own racking, four racks and not a quarrel.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed racking the mark draws, real and checked.
  static Play get dozen =>
      Play.standing(Pantries.at(3), Rules(12).byHeights());

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RackView(
          play: dozen,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
