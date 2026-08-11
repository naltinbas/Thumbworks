import 'package:flutter/material.dart';

import '../charm/charms.dart';
import '../charm/play.dart';
import 'charmview.dart';
import 'palette.dart';

/// The mark: the written row's one charm, held.
///
/// It is not a drawing of the game. The coins go through the same code
/// a finger goes through, and a test says the charm holds.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get held {
    var play = Play.of(Charms.at(3));
    var guard = 0;
    while (!play.isDone && guard++ < 12) {
      final (cell, coin) = play.next!;
      play = coin == null ? play.lift(cell) : play.lay(cell, coin);
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
                    padding: EdgeInsets.all(side * 0.05),
                    child: CustomPaint(
                      painter: CharmView(
                        play: held,
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
