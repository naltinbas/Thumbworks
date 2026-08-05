import 'package:flutter/material.dart';

import '../link/parish.dart';
import '../link/parishes.dart';
import '../link/play.dart';
import 'mapview.dart';
import 'palette.dart';

/// The mark: a small parish joined up for the least path there is.
///
/// It is not a drawing of the game. The paths are the ones the working out
/// settles on, cut through the same code a finger goes through, and a test
/// asserts the picture really is a parish the game would call joined up on the
/// cheapest there is.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the map behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Parish get parish => Rounds.at(1).parish;

  static Play get joined {
    var play = Play.of(parish, Rounds.answerFor(1));
    for (final trod in Rounds.answerFor(1).cut) {
      play = play.touch(trod);
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
                    padding: EdgeInsets.all(side * 0.02),
                    child: CustomPaint(
                      painter: MapView(
                        play: joined,
                        marking: const Marking(),
                        // No words in the mark: at forty eight points they are
                        // a smudge, and the picture is the paths.
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
