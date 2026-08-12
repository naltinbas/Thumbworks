import 'package:flutter/material.dart';

import '../beam/play.dart';
import '../beam/rules.dart';
import '../beam/worths.dart';
import 'beamview.dart';

/// The game's mark: the one clean six chosen, the beam nowhere
/// to be seen.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The choice the mark draws, the sweep's one six.
  static Play get six =>
      Play.standing(Worths.at(3), Rules.choice(6)!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BeamView(
          play: six,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
