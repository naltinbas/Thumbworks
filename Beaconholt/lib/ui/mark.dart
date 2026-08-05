import 'package:flutter/material.dart';

import '../watch/countries.dart';
import '../watch/fewest.dart';
import '../watch/play.dart';
import 'palette.dart';
import 'watchview.dart';

/// The mark: a small country with the fewest beacons on it, everything lit.
///
/// It is not a drawing of the game. The beacons are the ones the search
/// settles on, put up through the same code a finger goes through, and a test
/// asserts the picture really does watch every hill on the fewest there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onMoor = true});

  /// Whether to draw the moor behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onMoor;

  static Watchland get land => Watchlands.at(1);

  static Play get watched {
    var play = Play.of(land);
    for (final hill in Beacons.fewestFor(land.country).where) {
      play = play.turn(hill);
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
                if (onMoor)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.moor,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.05),
                    child: CustomPaint(
                      painter: WatchView(
                        play: watched,
                        pointing: -1,
                        // No names in the mark: at forty eight points they
                        // are a smudge, and the picture is the beacons.
                        labels: const TextStyle(
                          color: Color(0x00000000),
                          fontSize: 0.1,
                        ),
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
