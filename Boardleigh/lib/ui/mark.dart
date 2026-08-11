import 'package:flutter/material.dart';

import '../floor/play.dart';
import '../floor/rooms.dart';
import 'floorview.dart';
import 'palette.dart';

/// The mark: the little landing, half laid.
///
/// It is not a drawing of the game. The planks go through the same
/// code a finger goes through, and a test lays the rest of them.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get halfLaid {
    var play = Play.of(Rooms.at(0));
    play = play.lay(play.next!.$1, play.next!.$2);
    final plank = play.next!;
    return play.lay(plank.$1, plank.$2);
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
                if (onPanel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: FloorView(
                        play: halfLaid,
                        armed: -1,
                        showWords: false,
                        labels: const TextStyle(fontFamily: 'Roboto'),
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
