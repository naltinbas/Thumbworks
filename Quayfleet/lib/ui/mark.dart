import 'package:flutter/material.dart';

import '../berth/most.dart';
import '../berth/play.dart';
import '../berth/quay.dart';
import '../berth/quays.dart';
import 'bookview.dart';
import 'palette.dart';

/// The mark: a day worked up to the most ships it will take.
///
/// It is not a drawing of the game. The ships are the ones the rule settles
/// on, given the berth through the same code a finger goes through, and a
/// test asserts the picture really is a day nothing else will fit into, on as
/// many ships as there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the desk behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Quay get quay => Days.at(1).quay;

  static Play get worked {
    var play = Play.of(quay, Days.answerFor(1));
    for (final ship in Berthings.most(quay).taken) {
      play = play.take(ship);
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
                    padding: EdgeInsets.all(side * 0.14),
                    child: CustomPaint(
                      painter: BookView(
                        play: worked,
                        pointing: -1,
                        showMarks: false,
                        // No names and no hours in the mark: at forty eight
                        // points they are a smudge, and the picture is the
                        // ships.
                        showNames: false,
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
