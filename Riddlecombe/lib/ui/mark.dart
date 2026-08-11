import 'package:flutter/material.dart';

import '../weave/meshes.dart';
import '../weave/play.dart';
import 'palette.dart';
import 'weaveview.dart';

/// The mark: the three strands, woven clean.
///
/// It is not a drawing of the game. The weave goes through the same
/// code a finger goes through, and a test says it riddles.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get woven =>
      Play.of(Meshes.at(0)).comb(0, 1).comb(1, 2).comb(0, 1);

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
                      painter: WeaveView(
                        play: woven,
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
