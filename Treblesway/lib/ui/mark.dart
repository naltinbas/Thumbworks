import 'package:flutter/material.dart';

import '../ring/extent.dart';
import '../ring/peals.dart';
import '../ring/play.dart';
import 'palette.dart';
import 'towerview.dart';

/// The mark: four bells three changes into the full peal.
///
/// It is not a drawing of the game. Every pull follows the search through the
/// same code a finger goes through, and a test asserts the picture is a peal
/// that can still come round.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the chamber behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onVerge;

  static Play get threeIn {
    final peal = Peals.at(2);
    var play = Play.of(peal, Extent(peal.tower, goalRows: peal.goalRows));
    for (var pull = 0; pull < 3; pull++) {
      play = play.pull(play.next!);
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
                    padding: EdgeInsets.fromLTRB(
                        side * 0.06, side * 0.3, side * 0.06, side * 0.1),
                    child: CustomPaint(
                      painter: TowerView(
                        play: threeIn,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the bells.
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
