import 'package:flutter/material.dart';

import '../sift/fewest.dart';
import '../sift/play.dart';
import '../sift/puzzles.dart';
import 'frame.dart';
import 'palette.dart';

/// The mark: four lines and the five comparators that sort them.
///
/// It is not a drawing of the game. The network is the one the search finds
/// for four lines, built through the same code a finger goes through, and a
/// test asserts the picture really does sort every row there is in the fewest
/// there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBench = true});

  /// Whether to draw the bench behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onBench;

  static Sifting get sifting => Siftings.at(2);

  static Play get sorting {
    var play = Play.of(sifting);
    final rest = Fewest.fromHere(play.sieve)!.$2;
    for (var i = play.count; i < rest.crosses.length; i++) {
      play = play.add(rest.crosses[i].upper, rest.crosses[i].lower);
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
                    padding: EdgeInsets.all(side * 0.12),
                    child: CustomPaint(
                      painter: Frame(
                        play: sorting,
                        holding: -1,
                        showing: -1,
                        labels: const TextStyle(fontSize: 1),
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
