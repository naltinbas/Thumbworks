import 'package:flutter/material.dart';

import '../ruler/cuts.dart';
import '../ruler/play.dart';
import 'palette.dart';
import 'rulerview.dart';

/// The mark: the six inches, perfectly cut.
///
/// It is not a drawing of the game. The notches go through the same
/// code a finger goes through, and a test says the census is perfect.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onPanel;

  static Play get cutTrue =>
      Play.of(Cuts.at(1)).toggle(0).toggle(1).toggle(4).toggle(6);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onPanel)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.06),
                    child: CustomPaint(
                      painter: RulerView(
                        play: cutTrue,
                        pointing: -1,
                        showWords: false,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
