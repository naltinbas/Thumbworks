import 'package:flutter/material.dart';

import '../toss/call.dart';
import '../toss/play.dart';
import '../toss/wagers.dart';
import 'palette.dart';
import 'tossview.dart';

/// The mark: the ring of eight calls, every one with its beater.
///
/// It is not a drawing of the game. The ring comes through the same
/// painter the why uses, and a test asserts every arrow in it points from
/// a call to the call that beats it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBoard = true});

  /// Whether to draw the table boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onBoard;

  static Play get ringed =>
      Play.of(Wagers.at(1)).call(const Call(6));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onBoard)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.board,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.04),
                    child: CustomPaint(
                      painter: TossView(
                        play: ringed,
                        pointing: null,
                        showRing: true,
                        // No words in the mark: the picture is the ring.
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
