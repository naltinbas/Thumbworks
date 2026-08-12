import 'package:flutter/material.dart';

import '../round/cotes.dart';
import '../round/play.dart';
import 'coteview.dart';

/// The game's mark: a full fixture of six, five coats of rounds
/// covering every pair once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The fixture the mark draws, found by the sweep and checked.
  static Play get fixture {
    final cote = Cotes.at(3);
    final play = Play.of(cote);
    return Play.standing(cote, play.rules.fixture(const [])!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CoteView(
          play: fixture,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
