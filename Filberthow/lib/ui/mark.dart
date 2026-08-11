import 'package:flutter/material.dart';

import '../hoard/hoards.dart';
import '../hoard/play.dart';
import 'hoardview.dart';
import 'palette.dart';

/// The mark: the twenty, ringed into its clusters.
///
/// It is not a drawing of the game. The clusters come through the same
/// painter the why uses, and a test asserts they sum to the hoard.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onLog = true});

  /// Whether to draw the log boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onLog;

  static Play get ringed => Play.of(Hoards.at(0));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onLog)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.log,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: HoardView(
                        play: ringed,
                        pending: 0,
                        showClusters: true,
                        // No counts in the mark: the picture is the nuts
                        // and their rings.
                        showWords: false,
                        labels: const TextStyle(fontSize: 0.1),
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
