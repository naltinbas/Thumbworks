import 'package:flutter/material.dart';

import '../hedge/hedges.dart';
import '../hedge/play.dart';
import 'hedgeview.dart';
import 'palette.dart';

/// The mark: the last quarter with its worths written on.
///
/// It is not a drawing of the game. The stalks and their worths come
/// through the same painter the why uses, and a test asserts the sum is
/// the quarter it claims.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onGate = true});

  /// Whether to draw the gate boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onGate;

  static Play get standing => Play.of(Hedges.at(2));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onGate)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.gate,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: HedgeView(
                        play: standing,
                        pointing: null,
                        showWorth: false,
                        // No worths in the mark: the picture is the two
                        // colours of withy.
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
