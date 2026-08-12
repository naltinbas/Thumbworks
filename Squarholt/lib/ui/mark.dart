import 'package:flutter/material.dart';

import '../hoard/hoards.dart';
import '../hoard/play.dart';
import 'hoardview.dart';

/// The game's mark: three and four paying twenty-five, the
/// oldest right angle in the book, tiles gone gold.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The paid hoard the mark draws, real and checked.
  static Play get threeAndFour =>
      Play.standing(Hoards.at(1), 3, 4);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: HoardView(
          play: threeAndFour,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
