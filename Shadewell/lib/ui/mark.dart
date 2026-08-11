import 'package:flutter/material.dart';

import '../plot/play.dart';
import '../plot/plots.dart';
import 'palette.dart';
import 'plotview.dart';

/// The mark: the well, shaded home.
///
/// It is not a drawing of the game. The marks go through the same code
/// a finger goes through, and a test says every tally is kept.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get shaded {
    var play = Play.of(Plots.at(3));
    final picture = Plots.at(3).picture!;
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 5; col++) {
        play = play.touch(row, col);
        if (picture[row] & (1 << col) == 0) play = play.touch(row, col);
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
                    padding: EdgeInsets.all(side * 0.1),
                    child: CustomPaint(
                      painter: PlotView(
                        play: shaded,
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
