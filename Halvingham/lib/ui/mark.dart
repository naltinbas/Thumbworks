import 'package:flutter/material.dart';

import '../ledger/levels.dart';
import '../ledger/play.dart';
import 'ledgerview.dart';

/// The game's mark: thirteen by seven kept, the odd rows ticked and
/// ninety-one at the foot.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The keeping the mark draws, real and checked: the rule's rows for
  /// thirteen by seven.
  static Play get thirteenBySeven => Play.standing(Levels.at(0), Levels.at(0).rules.oddRows);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: LedgerView(
          play: thirteenBySeven,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
