import 'package:flutter/material.dart';

import '../yard/deals.dart';
import '../yard/play.dart';
import 'palette.dart';
import 'yardview.dart';

/// The mark: the hoarded fit's seven bales down in three piles, with the
/// thread through them.
///
/// It is not a drawing of the game. Every bale goes down where the snug fit
/// puts it, through the same code a finger goes through, and a test asserts
/// the picture is a morning done in the fewest piles there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBarn = true});

  /// Whether to draw the barn boards behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onBarn;

  static Play get done {
    var play = Play.of(Deals.at(1));
    while (!play.isDone) {
      play = play.put(play.next!);
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
                if (onBarn)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.barn,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: YardView(
                        play: done,
                        pointing: -1,
                        showThread: true,
                        // No weights in the mark: at forty eight points they
                        // are a smudge, and the picture is the piles.
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
