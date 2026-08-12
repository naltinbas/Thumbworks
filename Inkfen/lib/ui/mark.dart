import 'package:flutter/material.dart';

import '../ink/lines.dart';
import '../ink/play.dart';
import 'inkview.dart';

/// The game's mark: the full four inked home, its six strings
/// split into the three matchings, one ink each.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed inking the mark draws, real and checked.
  static Play get fullFour =>
      Play.standing(Lines.at(2), const [1, 2, 1, 2, 3, 3]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: InkView(
          play: fullFour,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
