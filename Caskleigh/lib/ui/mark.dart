import 'package:flutter/material.dart';

import '../cask/levels.dart';
import '../cask/play.dart';
import 'caskview.dart';

/// The game's mark: the first eleven casks poured into barrels, three
/// full and a sliver over, with the eighth cask lit because it holds
/// the most twos.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The run the mark draws, real and checked: a 1st to an 11th, which
  /// is 83711/27720 of a barrel.
  static Play get run => Play.standing(Levels.at(3), 1, 11);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CaskView(
          play: run,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
