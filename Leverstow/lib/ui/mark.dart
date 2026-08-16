import 'package:flutter/material.dart';

import '../lever/levels.dart';
import '../lever/play.dart';
import 'leverview.dart';

/// The game's mark: the loop Parrondo told it with, A once and B twice.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The loop the mark draws, real and checked: ABB, whose purse climbs
  /// 2416/35601 of a coin a round.
  static Play get famous => Play.standing(Levels.at(1), 'ABB');

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LeverView(
          play: famous,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
