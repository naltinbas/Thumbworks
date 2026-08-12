import 'package:flutter/material.dart';

import '../hall/halls.dart';
import '../hall/play.dart';
import 'hallview.dart';
import 'palette.dart';

/// The mark: the ell fully lit from its one bend.
///
/// It is not a drawing of the game. The hall goes through the same
/// code a finger goes through, and a test lights this very floor.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Halls.at(0));
    final watch = play.finished!;
    while (!play.isDone) {
      play = play.post(play.nextOf(watch)!);
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
                      painter: HallView(
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
