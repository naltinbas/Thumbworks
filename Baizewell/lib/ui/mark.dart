import 'package:flutter/material.dart';

import '../table/levels.dart';
import '../table/play.dart';
import 'tableview.dart';

/// The game's mark: the five by seven, ten bounces to the far pocket.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The table the mark draws, real and checked.
  static Play get fiveBySeven => Play.standing(Levels.at(0), 5, 7);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TableView(
          play: fiveBySeven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
