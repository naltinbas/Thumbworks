import 'package:flutter/material.dart';

import '../miu/levels.dart';
import '../miu/play.dart';
import 'sheetview.dart';

/// The game's mark: MUIIU derived, the tiles under their target.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The string the mark draws, real and checked: MUIIU in five steps.
  static Play get muiiu => Play.standing(Levels.at(3), 'MUIIU', 5);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SheetView(
          play: muiiu,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
