import 'package:flutter/material.dart';

import '../book/days.dart';
import '../book/play.dart';
import 'bookview.dart';
import 'palette.dart';

/// The mark: the busy day, its one full book kept.
///
/// It is not a drawing of the game. The bookings go through the same
/// code a finger goes through, and a test says the book is full.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get kept {
    var play = Play.of(Days.at(2));
    var guard = 0;
    while (!play.isDone && guard++ < 12) {
      play = play.toggle(play.next!);
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
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: BookView(
                        play: kept,
                        pointing: -1,
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
