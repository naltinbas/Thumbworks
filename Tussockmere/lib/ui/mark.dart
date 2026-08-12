import 'package:flutter/material.dart';

import '../mere/fields.dart';
import '../mere/play.dart';
import 'mereview.dart';
import 'palette.dart';

/// The mark: the three-field linked, gold from bank to bank.
///
/// It is not a drawing of the game. The marsh goes through the same
/// code a finger goes through, and a test links this very field.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Fields.at(0));
    var guard = 0;
    while (!play.isDone && guard++ < 10) {
      play = play.step(int.parse(play.next!));
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
                    padding: EdgeInsets.all(side * 0.09),
                    child: CustomPaint(
                      painter: MereView(
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
