import 'package:flutter/material.dart';

import '../green/greens.dart';
import '../green/play.dart';
import '../green/rules.dart';
import 'greenview.dart';
import 'palette.dart';

/// The mark: eight sides with the wheel's first round strung across.
///
/// It is not a drawing of the game. The pairings are the wheel's own for
/// round one, paired through the same code a finger goes through, and a
/// test asserts the round is full and fair.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPavilion = true});

  /// Whether to draw the pavilion boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPavilion;

  static Play get strung {
    var play = Play.of(Greens.at(3));
    for (final (a, b) in Rules.wheelRound(8, 0)) {
      play = play.pick(a).pick(b);
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
                if (onPavilion)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.pavilion,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.04),
                    child: CustomPaint(
                      painter: GreenView(
                        play: strung,
                        pointing: null,
                        showWheel: false,
                        // No numbers in the mark: the picture is the
                        // badges and their round of matches.
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
