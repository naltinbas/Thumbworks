import 'package:flutter/material.dart';

import '../sliver/levels.dart';
import '../sliver/play.dart';
import 'sliverview.dart';

/// The game's mark: the marks 8, 8 and 8, whose sliver is a seventh of
/// the field.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: cuts to the mark two
  /// thirds along every side, corners at (12/7, 24/7), (48/7, 12/7) and
  /// (24/7, 48/7), a seventh of the field.
  static Play get seventh => Play.standing(Levels.at(0), const [8, 8, 8]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SliverView(
          play: seventh,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
