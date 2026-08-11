import 'package:flutter/material.dart';

import '../moor/moors.dart';
import '../moor/play.dart';
import '../moor/rules.dart';
import 'moorview.dart';
import 'palette.dart';

/// The mark: the five mills, set by the built rows.
///
/// It is not a drawing of the game. The mills stand where the build puts
/// them, raised through the same code a finger goes through, and a test
/// asserts the moor is set windproof.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBarn = true});

  /// Whether to draw the barn boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onBarn;

  static Play get set {
    var play = Play.of(Moors.at(1));
    final built = Rules.built(5)!;
    for (var file = 0; file < 5; file++) {
      play = play.raise(file, built[file]);
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
                if (onBarn)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.barn,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: MoorView(
                        play: set,
                        pointing: null,
                        showBuilt: false,
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
