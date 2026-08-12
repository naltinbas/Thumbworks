import 'package:flutter/material.dart';

import '../fold/greens.dart';
import '../fold/play.dart';
import 'foldview.dart';
import 'palette.dart';

/// The mark: the full fold standing, two sheep swallowed.
///
/// It is not a drawing of the game. The fence goes through the same
/// code a finger goes through, and a test closes this very fence.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Greens.at(2));
    for (final spot in const [(0, 0), (0, 2), (3, 1)]) {
      play = play.set(spot);
    }
    return play.close();
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
                      painter: FoldView(
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
