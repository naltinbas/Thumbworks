import 'package:flutter/material.dart';

import '../cheese/blocks.dart';
import '../cheese/play.dart';
import 'cheeseview.dart';
import 'palette.dart';

/// The mark: the square two exchanges in, the mirror holding.
///
/// It is not a drawing of the game. Every bite runs through the same code
/// a finger goes through, and a test asserts the block is still on course
/// for its fewest.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onShelf = true});

  /// Whether to draw the shelf boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onShelf;

  static Play get twoIn {
    var play = Play.of(Blocks.at(1));
    for (var bite = 0; bite < 2; bite++) {
      final next = play.next!;
      play = play.touch(next.$1, next.$2);
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
                if (onShelf)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.shelf,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: CheeseView(
                        play: twoIn,
                        pointing: null,
                        showWhy: false,
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
