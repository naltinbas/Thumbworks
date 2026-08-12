import 'package:flutter/material.dart';

import '../acre/fields.dart';
import '../acre/play.dart';
import '../acre/rules.dart';
import 'acreview.dart';

/// The game's mark: the half over itself, two acres and a half
/// from four posts, one post held gold and one caught on the
/// rail, the odd rim that pays the half.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed paddock the mark draws, real and checked.
  static Play get paddock => Play.standing(
        Fields.at(3),
        Rules.paddock(4, twoA: 5, inside: 1)!,
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: AcreView(
          play: paddock,
          labels: const TextStyle(),
        ),
        child: const SizedBox.expand(),
      );
}
