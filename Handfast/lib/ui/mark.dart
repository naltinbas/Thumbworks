import 'package:flutter/material.dart';

import '../hire/fair.dart';
import '../hire/fairs.dart';
import '../hire/play.dart';
import 'boardview.dart';
import 'palette.dart';

/// The mark: a small board with as much of the work given out as it will take.
///
/// It is not a drawing of the game. The hands are the ones the walk settles
/// on, taken on through the same code a finger goes through, and a test
/// asserts the picture is a board the game would call finished on as many jobs
/// as can be covered.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the board behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Fair get fair => Days.at(1).fair;

  static Play get given {
    var play = Play.of(fair, Days.answerFor(1));
    final took = Days.answerFor(1).took;
    for (var job = 0; job < fair.jobs; job++) {
      if (took[job] >= 0) play = play.take(job, took[job]);
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
                if (onVerge)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.verge,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.1),
                    child: CustomPaint(
                      painter: BoardView(
                        play: given,
                        showShort: false,
                        pointing: (-1, -1),
                        // No words in the mark: at forty eight points they are
                        // a smudge, and the picture is the crosses.
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
