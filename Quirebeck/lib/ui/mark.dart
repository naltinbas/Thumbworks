import 'package:flutter/material.dart';

import '../quire/play.dart';
import '../quire/quires.dart';
import 'palette.dart';
import 'quireview.dart';

/// The mark: the fifth leaf's quire, one in-weave into its word.
///
/// It is not a drawing of the game. The stack goes through the same
/// code a button goes through, and a test finishes this very weaving.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening => Play.of(Quires.at(1)).step(true);

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
                    padding: EdgeInsets.all(side * 0.1),
                    child: CustomPaint(
                      painter: QuireView(
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
