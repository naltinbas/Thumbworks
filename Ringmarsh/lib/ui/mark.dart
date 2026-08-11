import 'package:flutter/material.dart';

import '../ring/play.dart';
import '../ring/watches.dart';
import 'palette.dart';
import 'ringview.dart';

/// The mark: the eight watch, set full.
///
/// It is not a drawing of the game. The ring goes through the same
/// code a finger goes through, and a test says every word is spelt.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get full {
    var play = Play.of(Watches.at(1));
    var guard = 0;
    while (!play.isFull && guard++ < 12) {
      play = play.turn(play.next!);
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
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: RingView(
                        play: full,
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
