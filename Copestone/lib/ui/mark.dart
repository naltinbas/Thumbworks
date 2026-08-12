import 'package:flutter/material.dart';

import '../wall/pitches.dart';
import '../wall/play.dart';
import 'palette.dart';
import 'wallview.dart';

/// The mark: the eight courses standing, raised by the walk itself.
///
/// It is not a drawing of the game. The wall goes through the same
/// code a heap-tap goes through, and a test raises this very wall.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Pitches.at(1));
    var guard = 0;
    while (!play.isDone && guard++ < 10) {
      play = play.lay(play.next!);
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
                    padding: EdgeInsets.all(side * 0.09),
                    child: CustomPaint(
                      painter: WallView(
                        play: opening,
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
