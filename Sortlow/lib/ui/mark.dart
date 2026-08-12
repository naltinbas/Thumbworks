import 'package:flutter/material.dart';

import '../mill/loads.dart';
import '../mill/play.dart';
import 'millview.dart';

/// The game's mark: the classic road of 3524, three grinds to
/// the stone.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed load the mark draws, real and checked.
  static Play get classic => Play.standing(Loads.at(1), 3524);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MillView(
          play: classic,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
