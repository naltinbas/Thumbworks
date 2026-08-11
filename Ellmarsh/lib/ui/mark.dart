import 'package:flutter/material.dart';

import '../cloth/benches.dart';
import '../cloth/play.dart';
import 'clothview.dart';
import 'palette.dart';

/// The mark: the first bench with the golden tick standing.
///
/// It is not a drawing of the game. The bolts and the tick come through
/// the same painter the why uses, and a test asserts the long bolt
/// reaches past the gap.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBench = true});

  /// Whether to draw the bench boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onBench;

  static Play get standing => Play.of(Benches.at(0));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onBench)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.bench,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: ClothView(
                        play: standing,
                        pending: 0,
                        showGap: true,
                        // No counts in the mark: the picture is the bolts
                        // and the golden tick.
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
