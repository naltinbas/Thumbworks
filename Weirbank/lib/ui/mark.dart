import 'package:flutter/material.dart';

import '../flow/play.dart';
import '../flow/works_list.dart';
import 'palette.dart';
import 'waterworks.dart';

/// The mark: a works running as full as it will go, with the cut on it.
///
/// It is not a drawing of the game. The amounts are the answer the search
/// found, put through the same code a finger goes through, and the two red
/// pipes are the ones that hold the whole thing back. A test asserts the works
/// in the picture really is full and really is held back by those.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onStone = true});

  /// Whether to draw the stone behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onStone;

  static Waterwork get waterwork => Waterworks.at(1);

  static Play get running {
    final one = waterwork;
    var play = Play.of(one.works, one.target);
    final most = play.answer;
    for (var pipe = 0; pipe < one.works.pipes.length; pipe++) {
      for (var turn = 0; turn < most.down[pipe]; turn++) {
        play = play.turn(pipe);
      }
    }
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;
          final play = running;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onStone)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.stone,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.04),
                    child: CustomPaint(
                      painter: Leat(
                        play: play,
                        pointing: -1,
                        showCut: false,
                        cut: const [],
                        // No words in the mark: at forty eight points they
                        // are a smudge, and the picture is the water.
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
