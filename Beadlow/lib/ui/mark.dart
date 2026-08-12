import 'package:flutter/material.dart';

import '../bead/play.dart';
import '../bead/rings.dart';
import 'beadview.dart';
import 'palette.dart';

/// The mark: the three-bead ring with its whole shelf strung.
///
/// It is not a drawing of the game. The stall goes through the same
/// code a finger goes through, and a test fills this very shelf.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Rings.at(0));
    var guard = 0;
    while (!play.isDone && guard++ < 10) {
      final missing = play.missing!;
      for (var at = 0; at < play.ring.beads; at++) {
        while (play.beads[at] != missing[at]) {
          play = play.dye(at);
        }
      }
      play = play.stringIt();
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
                      painter: BeadView(
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
