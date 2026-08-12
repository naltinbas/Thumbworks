import 'package:flutter/material.dart';

import '../braid/play.dart';
import '../braid/yards.dart';
import 'braidview.dart';
import 'palette.dart';

/// The mark: the doubles mid-braid, the chain half-climbed.
///
/// It is not a drawing of the game. The yard goes through the same
/// code a finger goes through, and a test finishes this very
/// braiding within its asking.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get opening {
    var play = Play.of(Yards.at(2));
    for (var braidings = 0; braidings < 2; braidings++) {
      final (one, two) = play.lightest!;
      play = play.braid(one, two);
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
                      painter: BraidView(
                        play: opening,
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
