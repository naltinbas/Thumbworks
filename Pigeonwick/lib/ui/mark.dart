import 'package:flutter/material.dart';

import '../post/play.dart';
import '../post/rounds.dart';
import 'postview.dart';

/// The game's mark: one of the nine, four letters posted and not
/// one of them home.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The posting the mark draws, found by the sweep and checked.
  static Play get nine {
    final round = Rounds.at(1);
    final play = Play.of(round);
    return Play.standing(round, play.rules.round(round.home)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PostView(
          play: nine,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
