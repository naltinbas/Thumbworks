import 'package:flutter/material.dart';

import '../table/parties.dart';
import '../table/play.dart';
import '../table/rules.dart';
import 'tableview.dart';

/// The game's mark: the one seating of three couples, every
/// husband two places round from his wife.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The landed seating the mark draws, real and checked.
  static Play get threeCouples =>
      Play.standing(Parties.at(0), Rules(3).landing()!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: TableView(
          play: threeCouples,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
