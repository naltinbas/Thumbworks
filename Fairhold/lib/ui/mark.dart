import 'package:flutter/material.dart';

import '../hold/consignments.dart';
import '../hold/play.dart';
import '../hold/rules.dart';
import 'holdview.dart';
import 'palette.dart';

/// The mark: the easy lading, stacked and standing.
///
/// It is not a drawing of the game. The choices are a real solution
/// applied through the same code a finger goes through, and a test
/// asserts the stack stands fair.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onShed = true});

  /// Whether to draw the shed boards behind it. Off for the Android
  /// adaptive icon, where the background is a layer of its own.
  final bool onShed;

  static Play get standing {
    var play = Play.of(Consignments.at(0));
    final solution = Rules.solutions(Consignments.at(0).crates).first;
    for (var crate = 0; crate < 4; crate++) {
      final (ns, ew) = solution[crate];
      play = play.cycle(crate, ns);
      var tried = play.cycle(crate, ew);
      if (tried.serves(crate, ew) != 'ew') {
        tried = tried.cycle(crate, ew);
      }
      play = tried;
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
                if (onShed)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.shed,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: HoldView(
                        play: standing,
                        pointing: null,
                        showRopes: false,
                        // No words in the mark: the picture is the
                        // standing stack.
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
