import 'package:flutter/material.dart';

import '../thread/boards.dart';
import '../thread/play.dart';
import 'palette.dart';
import 'weave.dart';

/// The mark: a three by three with two threads on it, filled.
///
/// It is not a drawing of the game — it is the game. The board goes through
/// [Play] the way a finger would and comes out through the same painter the
/// screen uses, so the logo cannot come to show something the rules do not
/// allow. The a thread runs alongside itself on the way down, which is worth
/// having in the picture: it is allowed, and half the answers need it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPeat = true});

  /// Whether to draw the peat behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onPeat;

  static const _board = Board(name: 'mark', rows: ['a.b', '...', 'ab.']);

  static Play get filled {
    var play = Play.of(_board);
    for (final at in const [1, 4, 3, 6]) {
      play = play.goTo(0, at);
    }
    for (final at in const [5, 8, 7]) {
      play = play.goTo(1, at);
    }
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onPeat)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.peat,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.1),
                    child: CustomPaint(
                      painter: Weave(
                        play: filled,
                        holding: -1,
                        pointing: -1,
                        rubbing: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
