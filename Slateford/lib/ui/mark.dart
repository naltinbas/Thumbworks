import 'package:flutter/material.dart';

import '../slate/levels.dart';
import '../slate/play.dart';
import 'slateview.dart';

/// The game's mark: a slate played out level, crosses by the tree
/// against the book, five moves each way.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The slate the mark draws, real and checked: the game the tree
  /// plays against the book from the open slate.
  static Play get level =>
      Play.standing(Levels.at(0), const [1, 1, 2, 2, 2, 1, 1, 1, 2]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SlateView(
          play: level,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
