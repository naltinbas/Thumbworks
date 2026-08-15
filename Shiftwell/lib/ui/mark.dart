import 'package:flutter/material.dart';

import '../rota/play.dart';
import '../rota/rotas.dart';
import '../rota/rules.dart';
import 'rotaview.dart';

/// The game's mark: the four fixed shifts finished the one way
/// they can be.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The finished rota the mark draws, real and checked.
  static Play get fourFixed =>
      Play.standing(Rotas.at(3), Rules(4, Rotas.at(3).fixed).landing()!);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RotaView(
          play: fourFixed,
          labels: const TextStyle(fontFamily: 'Roboto'),
        ),
        child: const SizedBox.expand(),
      );
}
