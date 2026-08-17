import 'package:flutter/material.dart';

import '../fold/levels.dart';
import '../fold/play.dart';
import 'foldview.dart';

/// The game's mark: Cerny's own fold, four whistles into the call that
/// gathers it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked: the first four
  /// whistles of the one call of nine that gathers the long fold.
  static Play get partWay =>
      Play.standing(Levels.at(3), const [1, 0, 0, 0]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FoldView(
          play: partWay,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
