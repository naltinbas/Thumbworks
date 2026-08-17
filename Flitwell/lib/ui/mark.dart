import 'package:flutter/material.dart';

import '../flit/levels.dart';
import '../flit/play.dart';
import 'flitview.dart';

/// The game's mark: the firm lane of the shared street, the one no group
/// of tenants can better.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The lane the mark draws, real and checked.
  static Play get lane =>
      Play.standing(Levels.at(3), Levels.at(3).firmLane);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: FlitView(
          play: lane,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
