import 'package:flutter/material.dart';

import '../yard/levels.dart';
import '../yard/play.dart';
import 'yardview.dart';

/// The game's mark: the hedges of counts 30 and 12, 832,040 and 144
/// long, and the yardstick of 8 that measures both.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: counts 30 and 12,
  /// hedges 832,040 and 144, yardstick 8, the sixth hedge, since 30 and
  /// 12 measure by six.
  static Play get thirtyTwelve => Play.standing(Levels.at(0), 30, 12);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: YardView(
          play: thirtyTwelve,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
