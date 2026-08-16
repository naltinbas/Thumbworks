import 'package:flutter/material.dart';

import '../ticket/levels.dart';
import '../ticket/play.dart';
import 'ticketview.dart';

/// The game's mark: the ticket 4 9 9 2 4 on its stub, passing.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The ticket the mark draws, real and checked: 4 9 9 2 4, adding 4,
  /// 9, 9, 4 and 4, thirty, one of the 10,000 that pass.
  static Play get ticket => Play.standing(Levels.at(0), const [4, 9, 9, 2, 4]);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TicketView(
          play: ticket,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
