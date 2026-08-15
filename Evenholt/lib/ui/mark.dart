import 'package:flutter/material.dart';

import '../share/play.dart';
import '../share/rules.dart';
import '../share/shares.dart';
import 'trayview.dart';

/// The game's mark: the eight shared by Prouhet's pattern, the
/// one share of eight that squares.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The dealt share the mark draws, real and checked.
  static Play get eight =>
      Play.standing(Shares.at(1), Rules(8, 2).prouhet()!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TrayView(
          play: eight,
          labels: const TextStyle(fontFamily: 'Roboto'),
          snug: true,
        ),
        child: const SizedBox.expand(),
      );
}
