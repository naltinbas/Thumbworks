import 'package:flutter/material.dart';

import '../reel/play.dart';
import '../reel/rounds.dart';
import '../reel/stable.dart';
import 'floor.dart';
import 'palette.dart';

/// The mark: a round of three, paired the one way that holds.
///
/// It is not a drawing of the game — it is a round, put together through the
/// same code a finger goes through and drawn by the painter the screen uses,
/// so the three lines in the logo are three couples nobody would swap out of.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onFloor = true});

  /// Whether to draw the floor behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onFloor;

  static Round get round => Rounds.at(0);

  static Play get paired {
    var play = Play.of(round);
    final answer = Stable.byAsking(round.hall);
    for (var caller = 0; caller < round.count; caller++) {
      play = play.pair(caller, answer[caller]);
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
                if (onFloor)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.floor,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.1),
                    child: CustomPaint(
                      painter: Floor(
                        play: paired,
                        holding: -1,
                        showSwaps: false,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the pairing.
                        names: const TextStyle(
                          color: Color(0x00000000),
                          fontSize: 1,
                        ),
                        lists: const TextStyle(
                          color: Color(0x00000000),
                          fontSize: 1,
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
