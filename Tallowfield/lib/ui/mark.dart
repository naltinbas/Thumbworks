import 'package:flutter/material.dart';

import '../garden/evenings.dart';
import '../garden/play.dart';
import 'gardenview.dart';
import 'palette.dart';

/// The mark: the shared bed's evening, the three hedges complaining at
/// once around the centre lantern.
///
/// It is not a drawing of the game. The garden, the complaints and the
/// lanterns come through the same painter an evening goes through, and a
/// test asserts the tallies name the centre lamp.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onWall = true});

  /// Whether to draw the wall stones behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onWall;

  static Play get tonight => Play.of(Evenings.at(1));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onWall)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.wall,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.02),
                    child: CustomPaint(
                      painter: GardenView(
                        play: tonight,
                        pointing: -1,
                        showBeds: false,
                        // No tallies in the mark: the picture is the
                        // hedges and the lanterns.
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
