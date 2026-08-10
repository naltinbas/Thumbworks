import 'package:flutter/material.dart';

import '../wath/bridges.dart';
import '../wath/fewest.dart';
import '../wath/play.dart';
import 'palette.dart';
import 'wathview.dart';

/// The mark: the famous four one crossing in, the quick pair over and the
/// lantern with them.
///
/// It is not a drawing of the game. The crossing follows the settling through
/// the same code a finger goes through, and a test asserts the picture is a
/// night still at seventeen.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the night behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Play get oneCrossing {
    var play = Play.of(Bridges.at(2), Crossings(Bridges.at(2)));
    final party = play.next!;
    for (var walker = 0; walker < play.bridge.count; walker++) {
      if ((party & (1 << walker)) != 0) play = play.pick(walker);
    }
    return play.cross();
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
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: WathView(
                        play: oneCrossing,
                        pointing: 0,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the lantern.
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
