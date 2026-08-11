import 'package:flutter/material.dart';

import '../wick/play.dart';
import '../wick/wicks.dart';
import 'palette.dart';
import 'wickview.dart';

/// The mark: the first lamp's board, one press from dark.
///
/// It is not a drawing of the game. The board is a live one, and a test
/// says its one answer is one press.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get lit => Play.of(Wicks.at(0));

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
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: WickView(play: lit, pointing: -1),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
