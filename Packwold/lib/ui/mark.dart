import 'package:flutter/material.dart';

import '../fit/boxes.dart';
import '../fit/guide.dart';
import '../fit/play.dart';
import 'ground.dart';
import 'palette.dart';

/// The mark: a small box with four pieces in it, packed.
///
/// It is not a drawing of the game, it is the game. The box goes through the
/// solver and then through [Play] the way a finger would, and comes out
/// through the same painter the screen uses — so the logo cannot come to show
/// a packing the rules do not allow, and a test asserts that the box in it is
/// really full.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onChalk = true});

  /// Whether to draw the ground behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onChalk;

  /// The first puzzle in the game: four pieces on a five by five, and the
  /// only way they go in. Small enough to read at forty eight points.
  static Puzzle get box => Puzzles.at(0);

  static Play get packed {
    var play = Play.of(box);
    for (final want in Guide.of(box).answer) {
      play = play.layAs(want);
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
                if (onChalk)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.chalk,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.09),
                    child: CustomPaint(
                      painter: Ground(
                        play: packed,
                        holding: -1,
                        pointing: const [],
                        wrong: false,
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
