import 'package:flutter/material.dart';

import '../ferry/ferries.dart';
import '../ferry/play.dart';
import 'ferryview.dart';
import 'palette.dart';

/// The mark: the keeper's crossing, goat aboard, one crossing rowed.
///
/// It is not a drawing of the game. The boat goes through the same
/// code a finger goes through, and a test rows the rest of the way.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get oneOver =>
      Play.of(Ferries.at(0)).board(0).board(2).row();

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
                    padding: EdgeInsets.all(side * 0.07),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(side * 0.1),
                      child: CustomPaint(
                        painter: FerryView(
                          play: oneOver,
                          pointing: const [],
                          showWords: false,
                          labels: const TextStyle(fontFamily: 'Roboto'),
                        ),
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
