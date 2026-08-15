import 'package:flutter/material.dart';

import '../mere/play.dart';
import '../mere/reaches.dart';
import '../mere/rules.dart';
import 'mereview.dart';

/// The game's mark: the third reach as set down, eight frogs in a
/// cross below the reeds, weighing exactly one against the aim.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The standing the mark draws, real and checked.
  static Play get thirdReach {
    final reach = Reaches.at(2);
    final rules = Rules(reach.reach, reach.army);
    // Two leaps in: the first two of the count's road, so the
    // picture has a frog above the reeds.
    var frogs = reach.army.toSet();
    for (var i = 0; i < 2; i++) {
      frogs = rules.after(frogs, rules.next(frogs)!);
    }
    return Play.standing(reach, frogs, moves: 2);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MereView(
          play: thirdReach,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
