import 'package:flutter/material.dart';

import '../raise/frame.dart';
import '../raise/frames.dart';
import '../raise/play.dart';
import 'frameview.dart';
import 'palette.dart';

/// The mark: a gable end part raised, with the crews on the next two timbers.
///
/// It is not a drawing of the game. Every day in it is a day the working out
/// settles on, raised through the same code a finger goes through, and a test
/// asserts the picture is a site the game could actually be standing on.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the site behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Frame get frame => Frames.at(1);

  static Play get part {
    var play = Play.of(frame, Frames.raiserFor(1), Frames.raisingFor(1));
    for (var day = 0; day < 3; day++) {
      for (final timber in play.next) {
        play = play.put(timber);
      }
      play = play.raise();
    }
    for (final timber in play.next) {
      play = play.put(timber);
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
                    padding: EdgeInsets.all(side * 0.05),
                    child: CustomPaint(
                      painter: FrameView(
                        play: part,
                        showRun: false,
                        pointing: -1,
                        // No words in the mark: at forty eight points they are
                        // a smudge, and the picture is the frame.
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
