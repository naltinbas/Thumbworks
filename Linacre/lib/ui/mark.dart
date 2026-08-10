import 'package:flutter/material.dart';

import '../wire/play.dart';
import '../wire/rounds.dart';
import 'netview.dart';
import 'palette.dart';

/// The mark: the toll bridge one exchange in, a cut answered by a brace.
///
/// It is not a drawing of the game. The cut is the winning first cut, the
/// brace is the machine's real answer, both through the same code a finger
/// goes through, and a test asserts the picture is a position the game could
/// really be standing in with the win still whole.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the dusk behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Play get oneExchange {
    final play = Play.of(Rounds.at(2), Rounds.gameFor(2));
    return play.touch(play.next!);
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
                    padding: EdgeInsets.all(side * 0.04),
                    child: CustomPaint(
                      painter: NetView(
                        play: oneExchange,
                        pointing: -1,
                        webs: null,
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the wires.
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
