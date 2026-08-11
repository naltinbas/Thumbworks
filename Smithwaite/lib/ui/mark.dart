import 'package:flutter/material.dart';

import '../forge/play.dart';
import '../forge/puzzles.dart';
import 'forgeview.dart';
import 'palette.dart';

/// The mark: the fair day five, six true moves in.
///
/// It is not a drawing of the game. Every move follows the walk through the
/// same code a finger goes through, and a test asserts the picture is a
/// puzzle still on course for its fewest.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBench = true});

  /// Whether to draw the bench boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onBench;

  static Play get sixIn {
    var play = Play.of(Puzzles.at(2));
    for (var move = 0; move < 6; move++) {
      play = play.move(play.next!);
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
                if (onBench)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.bench,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: ForgeView(
                        play: sixIn,
                        pointing: -1,
                        showCount: false,
                        // No figures in the mark: at forty eight points
                        // they are a smudge, and the picture is the rings.
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
