import 'package:flutter/material.dart';

import '../pail/errands.dart';
import '../pail/play.dart';
import 'pailview.dart';
import 'palette.dart';

/// The mark: the springside four, three pours in.
///
/// It is not a drawing of the game. The waterlines go through the same
/// code a finger goes through, and a test pours the rest of the way.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get threeIn {
    var play = Play.of(Errands.at(1));
    for (var pour = 0; pour < 3; pour++) {
      final next = play.next!;
      play = play.pour(next.$1, next.$2);
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
                      painter: PailView(
                        play: threeIn,
                        armed: null,
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
