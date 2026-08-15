import 'package:flutter/material.dart';

import '../set/dances.dart';
import '../set/play.dart';
import '../set/rules.dart';
import 'setview.dart';

/// The game's mark: the set of eleven paired off, four threads
/// all come to one.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The paired set the mark draws, real and checked.
  static Play get eleven =>
      Play.standing(Dances.at(1), Rules(11).landing()!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SetView(
          play: eleven,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
