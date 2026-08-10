import 'package:flutter/material.dart';

import '../mill/fewest.dart';
import '../mill/play.dart';
import '../mill/yards.dart';
import 'palette.dart';
import 'yardview.dart';

/// The mark: four stones at the moment the biggest crosses, half the work
/// done and half to come.
///
/// It is not a drawing of the game. Every move follows the table through the
/// same code a finger goes through, and a test asserts the picture really is
/// the half way point of a shortest way.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the yard behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Play get halfWay {
    final yard = Yards.at(2);
    var play = Play.of(yard, Moves(yard.stones));
    while (!play.biggestHome) {
      final (from, to) = play.next!;
      play = play.touch(from).touch(to);
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
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: YardView(
                        play: halfWay,
                        pointing: -1,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the stones.
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
