import 'package:flutter/material.dart';

import '../daisy/circles.dart';
import '../daisy/play.dart';
import '../daisy/rules.dart';
import 'daisyview.dart';

/// The game's mark: the daisy of seven, three petals round a
/// crowned heart, every pair sharing exactly one friend.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The settled circle the mark draws, real and checked.
  static Play get daisy =>
      Play.standing(Circles.at(3), Rules(7).daisy());

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DaisyView(
          play: daisy,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
