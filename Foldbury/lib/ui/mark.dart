import 'package:flutter/material.dart';

import '../fold/fewest.dart';
import '../fold/folds.dart';
import '../fold/play.dart';
import 'foldview.dart';
import 'palette.dart';

/// The mark: the seven gates watched on its three shepherds.
///
/// It is not a drawing of the game. The shepherds stand where the search
/// posts them, through the same code a finger goes through, and a test
/// asserts the picture is a night watched on the fewest there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the dusk behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Play get safe {
    final fold = Folds.at(2);
    final watch = Watches.of(fold);
    var play = Play.of(fold, watch);
    for (var gate = 0; gate < fold.count; gate++) {
      if ((watch.posted & (1 << gate)) != 0) play = play.touch(gate);
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
                if (onVerge)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.verge,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.03),
                    child: CustomPaint(
                      painter: FoldView(
                        play: safe,
                        pointing: -1,
                        showMatching: false,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the lanes.
                        showWords: false,
                        labels: const TextStyle(fontSize: 0.1),
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
