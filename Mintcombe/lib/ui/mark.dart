import 'package:flutter/material.dart';

import '../coin/levels.dart';
import '../coin/play.dart';
import 'coinview.dart';

/// The game's mark: the tidy top, 89, 34, 13, 5 and 2 laid in a row.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The picking the mark draws, real and checked: 89, 34, 13, 5 and 2,
  /// every other coin from the top, 143, the dearest price the tidy
  /// purse pays and the only picking that pays it.
  static Play get top => Play.standing(Levels.at(1), const [89, 34, 13, 5, 2]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CoinView(
          play: top,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
