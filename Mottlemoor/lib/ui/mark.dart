import 'package:flutter/material.dart';

import '../herd/moors.dart';
import '../herd/play.dart';
import 'herdview.dart';
import 'palette.dart';

/// The mark: the even herd one meeting in.
///
/// It is not a drawing of the game. The herds go through the same
/// code a finger goes through, and a test settles the rest.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get oneIn => Play.of(Moors.at(0)).meet(0, 1);

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
                    padding: EdgeInsets.all(side * 0.05),
                    child: CustomPaint(
                      painter: HerdView(
                        play: oneIn,
                        armed: -1,
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
