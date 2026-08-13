import 'package:flutter/material.dart';

import '../round/rules.dart';
import '../round/play.dart';
import '../round/tours.dart';
import 'roundview.dart';

/// The game's mark: a nine-round in gold on the star, one post
/// standing out alone, the closest the full round ever comes.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The standing round the mark draws, real and checked.
  static Play get nine =>
      Play.standing(Tours.at(3), Rules.round(9)!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RoundView(
          play: nine,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
