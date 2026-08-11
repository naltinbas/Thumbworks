import 'package:flutter/material.dart';

import '../tour/play.dart';
import '../tour/yards.dart';
import 'palette.dart';
import 'tourview.dart';

/// The mark: the five yard, nine true jumps in.
///
/// It is not a drawing of the game. Every jump follows the walk through
/// the same code a finger goes through, and a test asserts the round can
/// still be ridden home.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onStable = true});

  /// Whether to draw the stable boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onStable;

  static Play get nineIn {
    var play = Play.of(Yards.at(2));
    for (var jump = 0; jump < 9; jump++) {
      play = play.ride(play.next!);
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
                if (onStable)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.stable,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: TourView(
                        play: nineIn,
                        pointing: -1,
                        showColours: false,
                        // No tallies in the mark: the picture is the trail.
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
