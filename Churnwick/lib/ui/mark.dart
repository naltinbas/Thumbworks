import 'package:flutter/material.dart';

import '../churn/dairies.dart';
import '../churn/dairy.dart';
import '../churn/play.dart';
import 'dairyview.dart';
import 'palette.dart';

/// The mark: a dairy at the last step of the shortest way through it, with
/// the milk standing at the amount it was after.
///
/// It is not a drawing of the game. Every pour is one the search settles on,
/// done through the same code a finger goes through, and a test asserts the
/// picture really is a morning the game would call finished on the fewest
/// goes there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the dairy wall behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onVerge;

  static Dairy get dairy => Mornings.at(0).dairy;

  static Play get measured {
    var play = Play.of(dairy, Mornings.answerFor(0));
    for (final pour in Mornings.answerFor(0).how) {
      play = play.doIt(pour);
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
                    padding: EdgeInsets.all(side * 0.13),
                    child: CustomPaint(
                      painter: DairyView(
                        play: measured,
                        showSteps: false,
                        // No words in the mark: at forty eight points they are
                        // a smudge, and the picture is the milk.
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
