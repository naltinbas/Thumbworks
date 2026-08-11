import 'package:flutter/material.dart';

import '../garden/garths.dart';
import '../garden/play.dart';
import '../garden/rules.dart';
import 'garthview.dart';
import 'palette.dart';

/// The mark: the four beds, bloomed by the doubled square.
///
/// It is not a drawing of the game. Every posy went in through the same
/// code a finger goes through, and a test asserts the garth is sound.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBench = true});

  /// Whether to draw the bench boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onBench;

  static Play get bloomed {
    var play = Play.of(Garths.at(1));
    final planting = Rules.planted(4)!;
    for (var bed = 0; bed < 16; bed++) {
      play = play.plant(bed, planting[bed].$1, planting[bed].$2);
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
                      painter: GarthView(
                        play: bloomed,
                        armedFlower: -1,
                        armedColour: -1,
                        pointing: -1,
                        showPlanting: false,
                        // No bench chips in the mark: the picture is the
                        // bloomed beds.
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
