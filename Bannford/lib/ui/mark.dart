import 'package:flutter/material.dart';

import '../banns/parties.dart';
import '../banns/play.dart';
import 'bannsview.dart';
import 'palette.dart';

/// The mark: the mild house, settled.
///
/// It is not a drawing of the game. The pairing goes through the same
/// code a finger goes through, and a test says nobody in it elopes.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get settled => Play.of(Parties.at(2)).wed(0, 1).wed(2, 3);

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
                      painter: BannsView(
                        play: settled,
                        armed: -1,
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
