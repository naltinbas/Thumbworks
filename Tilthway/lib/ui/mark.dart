import 'package:flutter/material.dart';

import '../tilth/play.dart';
import '../tilth/tilths.dart';
import 'palette.dart';
import 'tilthview.dart';

/// The mark: the eight seeds, as the unsowing grew them.
///
/// It is not a drawing of the game. The board is the only winnable board
/// of its size, and a test says so by playing it home.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBarnwood = true});

  /// Whether to draw the barn boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onBarnwood;

  static Play get grown => Play.of(Tilths.at(1));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onBarnwood)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.barnwood,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: TilthView(
                        play: grown,
                        pointing: -1,
                        showSowable: false,
                        // No numbers in the mark: the picture is the
                        // barn and the seeded furrows.
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
