import 'package:flutter/material.dart';

import '../ley/greens.dart';
import '../ley/play.dart';
import '../ley/rules.dart';
import 'leyview.dart';
import 'palette.dart';

/// The mark: the six stones standing, one of the green's two rings.
///
/// It is not a drawing of the game. The ring goes through the same
/// code a finger goes through, and a test raises this very ring.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Greens.at(1));
    for (final berth in Rules.complete(3, const [], 6)!) {
      play = play.raise(berth);
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
                      painter: LeyView(
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
