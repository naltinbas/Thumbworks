import 'package:flutter/material.dart';

import '../round/play.dart';
import '../round/rounds_list.dart';
import '../round/shortest.dart';
import 'fen.dart';
import 'palette.dart';

/// The mark: a small round, driven the shortest way there is.
///
/// It is not a drawing of the game. The order is the one the working finds,
/// driven through the same code a finger goes through, and a test asserts the
/// picture really is the shortest round on that map.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onGround = true});

  /// Whether to draw the ground behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onGround;

  static Round get round => Rounds.at(1);

  static Play get driven {
    var play = Play.of(round);
    for (final stop in Rounder(round.moor).work().order.skip(1)) {
      play = play.goTo(stop);
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
                if (onGround)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.ground,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: Fen(
                        play: driven,
                        pointing: -1,
                        // No names in the mark: at forty eight points they
                        // are a smudge, and the picture is the round.
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
