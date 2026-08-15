import 'package:flutter/material.dart';

import '../party/levels.dart';
import '../party/play.dart';
import 'partyview.dart';

/// The game's mark: twenty-three candles, the party where a shared
/// birthday first turns more likely than not.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The party the mark draws, real and checked: twenty-three guests.
  static Play get twentyThree => Play.standing(Levels.at(0), 23);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PartyView(
          play: twentyThree,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
