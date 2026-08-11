import 'package:flutter/material.dart';

import '../alley/frames.dart';
import '../alley/play.dart';
import 'alleyview.dart';
import 'palette.dart';

/// The mark: the first frame after the middle knock, two mirrored
/// pairs standing.
///
/// It is not a drawing of the game. The knock goes through the same
/// code a finger goes through, and a test says the count is nought.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get middled => Play.of(Frames.at(0)).knockOne(0, 2);

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
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: AlleyView(
                        play: middled,
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
