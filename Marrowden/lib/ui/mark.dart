import 'package:flutter/material.dart';

import '../show/play.dart';
import '../show/shows.dart';
import 'palette.dart';
import 'showview.dart';

/// The mark: the four-marrow bench, one waved by and a best-yet up.
///
/// It is not a drawing of the game. The bench goes through the same
/// code a button goes through, and a test judges this very sitting.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening => Play.of(Shows.at(0), const [
        [1, 3, 0, 2],
      ]).wave();

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
                      painter: ShowView(
                        play: opening,
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
