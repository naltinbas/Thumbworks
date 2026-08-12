import 'package:flutter/material.dart';

import '../basket/fens.dart';
import '../basket/play.dart';
import '../basket/rules.dart';
import 'fenview.dart';

/// The game's mark: the six taken, the middle shelf entire and
/// nothing else on earth reaching it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon,
  /// which brings its own.
  final bool onVerge;

  /// The picking the mark draws, the sweep's one six.
  static Play get six =>
      Play.standing(Fens.at(3), Rules.family(6)!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FenView(
          play: six,
          showWords: false,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
