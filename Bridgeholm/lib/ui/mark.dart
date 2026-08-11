import 'package:flutter/material.dart';

import '../walk/play.dart';
import '../walk/towns.dart';
import 'palette.dart';
import 'walkview.dart';

/// The mark: the mill round, two bridges into its walk.
///
/// It is not a drawing of the game. The walk goes through the same code
/// a finger goes through, and a test walks the rest of it home.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get twoIn => Play.of(Towns.at(0)).stand(0).cross(0).cross(1);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onPanel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.04),
                    child: CustomPaint(
                      painter: WalkView(
                        play: twoIn,
                        pointingBridge: -1,
                        pointingGround: -1,
                        showWords: false,
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
