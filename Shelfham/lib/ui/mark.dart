import 'package:flutter/material.dart';

import '../shelf/play.dart';
import '../shelf/shelves.dart';
import 'shelfview.dart';

/// The game's mark: the stair down, the one ordering of four
/// with every gap stepping.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The ordering the mark draws, found by the sweep and checked.
  static Play get stair {
    final shelf = Shelves.at(1);
    final play = Play.of(shelf);
    return Play.standing(shelf, play.rules.ordering(shelf.asked)!);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ShelfView(
          play: stair,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
