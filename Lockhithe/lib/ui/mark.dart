import 'package:flutter/material.dart';

import '../quay/berths.dart';
import '../quay/play.dart';
import '../quay/stow.dart';
import 'palette.dart';
import 'quayview.dart';

/// The mark: eight lockers with their loops roped over them.
///
/// It is not a drawing of the game. The stow's loops come through the
/// same painter the why uses, and a test asserts they cover every locker
/// once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onWharf = true});

  /// Whether to draw the wharf boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onWharf;

  /// Loops (1 5 3)(2 6)(4 7 8), in sailors' numbers.
  static Play get roped => Play.of(
        Berths.at(2),
        const Stow([4, 5, 0, 6, 2, 1, 7, 3]),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onWharf)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.wharf,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: side * 0.05,
                      vertical: side * 0.1,
                    ),
                    child: CustomPaint(
                      painter: QuayView(
                        play: roped,
                        pointing: -1,
                        showLoops: true,
                        // No numbers in the mark: the picture is the
                        // doors and the ropes.
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
