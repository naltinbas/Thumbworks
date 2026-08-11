import 'package:flutter/material.dart';

import '../post/letters.dart';
import '../post/play.dart';
import 'palette.dart';
import 'postview.dart';

/// The mark: the first letter, paid with two of each.
///
/// It is not a drawing of the game. Every stamp went on through the same
/// code a finger goes through, and a test asserts the letter is paid to
/// the penny.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onCounter = true});

  /// Whether to draw the counter boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onCounter;

  static Play get paid => Play.of(Letters.at(0))
      .affix(true)
      .affix(true)
      .affix(false)
      .affix(false);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onCounter)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.counter,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: PostView(
                        play: paid,
                        showWalk: false,
                        // No values in the mark: the picture is the
                        // envelope and its stamps.
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
