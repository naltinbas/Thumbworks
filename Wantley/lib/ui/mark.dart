import 'package:flutter/material.dart';

import '../wish/play.dart';
import '../wish/rules.dart';
import '../wish/wishes.dart';
import 'wishview.dart';

/// The game's mark: the one way itself, the only treading that
/// lands 4, 4, 3, 3, 2, every farm green with its wish.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed treading the mark draws, real and checked.
  static Play get oneWay => Play.standing(
        Wishes.at(3),
        Rules(5).build(Wishes.at(3).wishes)!,
      );

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: WishView(
          play: oneWay,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
