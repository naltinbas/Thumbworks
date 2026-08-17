import 'package:flutter/material.dart';

import '../hedge/levels.dart';
import '../hedge/play.dart';
import 'hedgeview.dart';

/// The game's mark: a hedge of seven posts that peels to one, with the
/// longest walk running behind it and the middle lit at its halfway
/// mark.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The hedge the mark draws, real and checked: post 1 holding two
  /// posts, each of those holding two more, four steps end to end.
  static Play get hedge => Play.standing(Levels.at(0), const [1, 2, 2, 3, 3]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HedgeView(
          play: hedge,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
