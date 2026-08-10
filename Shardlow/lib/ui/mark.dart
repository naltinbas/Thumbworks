import 'package:flutter/material.dart';

import '../drop/fewest.dart';
import '../drop/ladders.dart';
import '../drop/play.dart';
import 'ladderview.dart';
import 'palette.dart';

/// The mark: the ten rung ladder two sound drops in, one pot broken on the
/// way and the band of what is still possible showing.
///
/// It is not a drawing of the game. Both drops follow the table through the
/// same code a finger goes through, and a test asserts the picture is a
/// morning the game could really be standing in, still at par.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the yard behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Play get twoIn {
    var play = Play.of(Ladders.at(1), Drops(Ladders.at(1).pots));
    play = play.drop(play.next!);
    play = play.drop(play.next!);
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
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: LadderView(
                        play: twoIn,
                        pointing: -1,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the ladder.
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
