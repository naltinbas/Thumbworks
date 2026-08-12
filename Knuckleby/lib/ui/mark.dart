import 'package:flutter/material.dart';

import '../bones/benches.dart';
import '../bones/play.dart';
import 'bonesview.dart';
import 'palette.dart';

/// The mark: the other bones cut true, the table all green.
///
/// It is not a drawing of the game. The bench goes through the same
/// code a finger goes through, and a test makes this very trade.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Benches.at(1));
    const other = ([1, 2, 2, 3, 3, 4], [1, 3, 4, 5, 6, 8]);
    for (var face = 0; face < 6; face++) {
      while (play.one[face] != other.$1[face]) {
        play = play.cut(0, face);
      }
      while (play.two[face] != other.$2[face]) {
        play = play.cut(1, face);
      }
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
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: BonesView(
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
