import 'package:flutter/material.dart';

import '../chase/maps.dart';
import '../chase/play.dart';
import '../chase/tablebase.dart';
import 'palette.dart';
import 'warren_view.dart';

/// The mark: a map with the two of them on it, one move from the end.
///
/// It is not a drawing of the game — it is a chase, played out through the
/// table and the same code a finger goes through, and drawn by the painter
/// the screen uses. The seeker is one path away and the runner has nowhere
/// left to go, which is the whole of this game in one picture.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onField = true});

  /// Whether to draw the field behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onField;

  /// The green: a triangle of paths with three lanes off it, which is the
  /// smallest map here that looks like a map.
  static Warren get warren => Warrens.at(3);

  /// The chase played to one move from the catch.
  static Play get nearlyOver {
    final map = warren;
    var play = Play.of(map, Tablebase(map.chart));
    while (play.left > 1 && !play.isDone) {
      play = play.move(play.next!);
    }
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;
          final play = nearlyOver;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onField)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.field,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: WarrenView(
                        play: play,
                        canGo: const [],
                        pointing: -1,
                        // No names in the mark: at forty eight points they
                        // are a smudge, and the picture is the chase.
                        labels: const TextStyle(
                          color: Color(0x00000000),
                          fontSize: 1,
                        ),
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
