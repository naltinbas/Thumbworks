import 'package:flutter/material.dart';

import '../griddle/batches.dart';
import '../griddle/play.dart';
import 'griddleview.dart';
import 'palette.dart';

/// The mark: the tall order three good flips in.
///
/// It is not a drawing of the game. Every flip follows the walk through the
/// same code a finger goes through, and a test asserts the picture is a
/// batch still on course for its fewest.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onHearth = true});

  /// Whether to draw the hearth boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onHearth;

  static Play get threeIn {
    var play = Play.of(Batches.at(4));
    for (var flip = 0; flip < 3; flip++) {
      play = play.flip(play.next!);
    }
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onHearth)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.hearth,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: GriddleView(
                        play: threeIn,
                        pointing: -1,
                        showGaps: false,
                        // No sizes in the mark: at forty eight points they
                        // are a smudge, and the picture is the stack.
                        showWords: false,
                        labels: const TextStyle(fontSize: 0.1),
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
