import 'package:flutter/material.dart';

import '../album/levels.dart';
import '../album/play.dart';
import 'albumview.dart';

/// The game's mark: the album page of six stickers.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onVerge = true});

  /// Whether the night sits behind it. Off for the adaptive
  /// icon, which brings its own.
  final bool onVerge;

  /// The setting the mark draws, real and checked: a set of six at its
  /// coin-toss point, thirteen packets, The Half Dozen's own aim.
  static Play get six => Play.standing(Levels.at(0), 6, 13);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: AlbumView(
          play: six,
          labels: const TextStyle(fontFamily: 'Roboto'),
          bare: true,
        ),
        child: const SizedBox.expand(),
      );
}
