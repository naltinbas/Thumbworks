import 'package:flutter/material.dart';

import '../glint/levels.dart';
import '../glint/play.dart';
import 'glintview.dart';

/// The game's mark: the light taking the bounce with matching angles,
/// two legs of five paces each.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive icon, which
  /// brings its own.
  final bool onVerge;

  /// The bounce the mark draws, real and checked.
  static Play get shot => Play.at(Levels.at(3), 5);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GlintView(
          play: shot,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
