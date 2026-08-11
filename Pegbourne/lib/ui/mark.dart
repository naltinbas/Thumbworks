import 'package:flutter/material.dart';

import '../code/play.dart';
import '../code/riddles.dart';
import 'codeview.dart';
import 'palette.dart';

/// The mark: the first riddle answered.
///
/// It is not a drawing of the game. The pegs go through the same code
/// a finger goes through, and a test says every row agrees.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get answered {
    var play = Play.of(Riddles.at(0));
    var guard = 0;
    while (!play.isDone && guard++ < 40) {
      final (slot, colour) = play.next!;
      while (play.slots[slot] != colour) {
        play = play.cycle(slot);
      }
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
                if (onPanel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: CodeView(
                        play: answered,
                        pointing: null,
                        showWords: false,
                        labels: const TextStyle(fontFamily: 'Roboto'),
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
