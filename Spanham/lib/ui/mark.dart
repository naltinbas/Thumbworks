import 'package:flutter/material.dart';

import '../row/levels.dart';
import '../row/play.dart';
import 'palette.dart';
import 'rowview.dart';

/// The mark: the four pairs, set.
///
/// It is not a drawing of the game. Every block sits where the search put
/// it, through the same code a finger goes through, and a test asserts
/// every pair holds its own number of seats apart.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onToybox = true});

  /// Whether to draw the toybox boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onToybox;

  static Play get set {
    var play = Play.of(Levels.at(1));
    while (!play.isSet) {
      play = play.place(play.next!);
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
                if (onToybox)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.toybox,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: side * 0.05,
                      vertical: side * 0.18,
                    ),
                    child: CustomPaint(
                      painter: RowView(
                        play: set,
                        pointing: -1,
                        showSums: false,
                        // No numbers in the mark: the picture is the
                        // coloured blocks on their shelf.
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
