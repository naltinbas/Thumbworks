import 'package:flutter/material.dart';

import '../coins/levels.dart';
import '../coins/play.dart';
import 'tableview.dart';

/// The game's mark: the ten turned in three, the point at the bottom
/// and the ghost of the upright behind.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The laying the mark draws, real and checked: the ten at the aim.
  static Play get ten => Play.standing(Levels.at(2), Play.aimFor(Levels.at(2)), moves: 3);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TableView(
          play: ten,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
