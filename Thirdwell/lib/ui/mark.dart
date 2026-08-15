import 'package:flutter/material.dart';

import '../deal/play.dart';
import '../deal/walks.dart';
import 'dealview.dart';

/// The game's mark: the twentieth walked, middle then top then
/// bottom, the stack shown with counter 17 twentieth from the top.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The walk the mark draws, real and checked.
  static Play get twentieth => Play.standing(Walks.at(3), const [1, 0, 2]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DealView(
          play: twentieth,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
