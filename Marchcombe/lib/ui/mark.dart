import 'package:flutter/material.dart';

import '../dye/land.dart';
import '../dye/lands.dart';
import '../dye/play.dart';
import 'mapview.dart';
import 'palette.dart';

/// The mark: a small estate painted in the fewest dyes there are.
///
/// It is not a drawing of the game. The dyes are the ones the search settles
/// on, put on through the same code a finger goes through, and a test asserts
/// the picture really is a proper painting on as few dyes as there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the table behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Land get land => Estates.at(2).land;

  static Play get painted {
    var play = Play.of(land, Estates.answerFor(2));
    for (var field = 0; field < land.count; field++) {
      play = play.paint(field, play.painting.dyes[field]);
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
                    padding: EdgeInsets.all(side * 0.09),
                    child: CustomPaint(
                      painter: MapView(
                        play: painted,
                        pointing: -1,
                        showRing: false,
                        // No names in the mark: at forty eight points they are
                        // a smudge, and the picture is the fields.
                        showNames: false,
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
