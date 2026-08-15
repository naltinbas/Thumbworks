import 'package:flutter/material.dart';

import '../plaid/levels.dart';
import '../plaid/play.dart';
import '../plaid/rules.dart';
import 'plaidview.dart';

/// The game's mark: Sylvester's eight, every two rows agreeing in four.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The plaid the mark draws, real and checked: Sylvester's eight on
  /// the eight, four rows given.
  static Play get sylvester => Play.standing(Levels.at(3), Rules.sylvester(8));

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PlaidView(
          play: sylvester,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
