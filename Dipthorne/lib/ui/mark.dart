import 'package:flutter/material.dart';

import '../ring/play.dart';
import '../ring/rings.dart';
import 'palette.dart';
import 'ringview.dart';

/// The mark: the thirteen, five chants in, you in the safe seat.
///
/// It is not a drawing of the game. Every chant runs through the same code
/// a finger goes through, and a test asserts you are standing in the seat
/// the rhyme cannot find.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onWall = true});

  /// Whether to draw the wall bricks behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onWall;

  static Play get fiveIn {
    var play = Play.of(Rings.at(1)).choose(Rings.at(1).safe);
    for (var chant = 0; chant < 5; chant++) {
      play = play.step();
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
                if (onWall)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.wall,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.05),
                    child: CustomPaint(
                      painter: RingView(
                        play: fiveIn,
                        pointing: -1,
                        showSafe: false,
                        // No numbers in the mark: at forty eight points
                        // they are a smudge, and the picture is the ring.
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
