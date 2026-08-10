import 'package:flutter/material.dart';

import '../forme/chases.dart';
import '../forme/play.dart';
import 'formeview.dart';
import 'palette.dart';

/// The mark: the Ink chase two slides from reading right.
///
/// It is not a drawing of the game. The arrangement is the shipped start slid
/// four steps along its own shortest way, through the same code a finger goes
/// through, and a test asserts the picture really is two slides from locking.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the bench behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onVerge;

  static Play get nearlyDone {
    var play = Play.of(Formes.at(0), Formes.slidesFor(0));
    for (var step = 0; step < 4; step++) {
      play = play.slide(play.next!);
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
                    padding: EdgeInsets.all(side * 0.1),
                    child: CustomPaint(
                      painter: FormeView(
                        play: nearlyDone,
                        pointing: -1,
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
