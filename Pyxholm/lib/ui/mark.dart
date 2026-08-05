import 'package:flutter/material.dart';

import '../assay/boxes.dart';
import '../assay/play.dart';
import '../assay/pyx.dart';
import 'beamview.dart';
import 'palette.dart';

/// The mark: a beam with coins on it, tipped the way it really tips.
///
/// It is not a drawing of the game. The weighing is the one the searching lays
/// out first, put on the pans through the same code a finger goes through, and
/// a test asserts the picture is a real weighing that told the game something.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the counting house behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onVerge;

  static Pyx get pyx => Boxes.at(3);

  static Play get weighed {
    var play = Play.of(pyx, Boxes.assayFor(3));
    final first = play.next!;
    for (final coin in first.left) {
      play = play.move(coin);
    }
    for (final coin in first.right) {
      play = play.move(coin).move(coin);
    }
    return play.weigh();
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
                    padding: EdgeInsets.fromLTRB(
                        side * 0.1, side * 0.12, side * 0.1, side * 0.62),
                    child: CustomPaint(
                      painter: BeamView(
                        play: weighed,
                        pointing: null,
                        // No words in the mark: at forty eight points they are
                        // a smudge, and the picture is the beam.
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
