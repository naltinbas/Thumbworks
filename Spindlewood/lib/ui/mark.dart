import 'package:flutter/material.dart';

import '../tower/play.dart';
import '../tower/spindles.dart';
import 'palette.dart';
import 'towerview.dart';

/// The mark: the three rounds, three of the seven moves in.
///
/// It is not a drawing of the game. The board goes through the same
/// code a finger goes through, and a test plays the rest of it home.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get threeIn {
    var play = Play.of(Spindles.at(0));
    for (var move = 0; move < 3; move++) {
      final next = play.next!;
      play = play.move(next.$1, next.$2);
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
                      painter: TowerView(
                        play: threeIn,
                        lifted: -1,
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
