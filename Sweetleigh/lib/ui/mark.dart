import 'package:flutter/material.dart';

import '../string/play.dart';
import '../string/rules.dart';
import '../string/shares.dart';
import 'stringview.dart';

/// The game's mark: reds-then-blues shared by the window, the two
/// cuts round the middle four.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The shared string the mark draws, real and checked.
  static Play get twoCuts =>
      Play.standing(Shares.at(1), Rules('RRRRBBBB').window()!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StringView(
          play: twoCuts,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
