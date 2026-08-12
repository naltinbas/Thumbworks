import 'package:flutter/material.dart';

import '../stack/boxsets.dart';
import '../stack/play.dart';
import '../stack/rules.dart';
import 'stackview.dart';

/// The game's mark: the old four settled, sixteen tiles with
/// every wall wearing every paint once.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The settling the mark draws, found by the sweep and checked.
  static Play get settled {
    final set = BoxSets.at(3);
    final aim = Rules.settling(set.boxes)!;
    // Stand each box by searching its turnings for the aimed walls.
    final stood = <(int, int, int, int)>[];
    for (var box = 0; box < set.count; box++) {
      searching:
      for (var axis = 0; axis < 3; axis++) {
        for (var flipP = 0; flipP < 2; flipP++) {
          for (var flipQ = 0; flipQ < 2; flipQ++) {
            for (var spin = 0; spin < 4; spin++) {
              final turn = (axis, flipP, flipQ, spin);
              if (Play.wallsOf(set.boxes[box], turn) == aim[box]) {
                stood.add(turn);
                break searching;
              }
            }
          }
        }
      }
    }
    return Play.standing(set, stood);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StackView(
          play: settled,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
