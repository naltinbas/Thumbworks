import 'package:flutter/material.dart';

import '../till/play.dart';
import '../till/rounds.dart';
import 'counterview.dart';
import 'palette.dart';

/// The mark: four bob paid the right way, two florins on the tray.
///
/// It is not a drawing of the game. The coins were put down through the same
/// code a finger goes through, and a test asserts the picture really is the
/// amount met in the fewest coins there are.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether to draw the counter behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onVerge;

  static Play get paid {
    var play = Play.of(Rounds.at(2), Rounds.fewestsFor(2));
    while (!play.isDone) {
      play = play.put(play.next!);
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
                if (onVerge)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.verge,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: CounterView(
                      play: paid,
                      pointing: -1,
                      justTray: true,
                      labels: const TextStyle(fontFamily: 'Roboto'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
