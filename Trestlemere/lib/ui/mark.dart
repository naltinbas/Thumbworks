import 'package:flutter/material.dart';

import '../table/levels.dart';
import '../table/play.dart';
import 'tableview.dart';

/// The game's mark: the six guests at three tables of one, two and
/// three, which is the only shape three different tables can take.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The seating the mark draws, real and checked.
  static Play get supper =>
      Play.seated(Levels.at(1), const [0, 1, 1, 2, 2, 2]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TableView(
          play: supper,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
