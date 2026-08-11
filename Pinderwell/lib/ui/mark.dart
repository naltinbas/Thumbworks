import 'package:flutter/material.dart';

import '../drive/fields.dart';
import '../drive/play.dart';
import 'fieldview.dart';
import 'palette.dart';

/// The mark: the long acre with the ladder on the grass and the ewe where
/// she starts.
///
/// It is not a drawing of the game. The board, the rungs and the ewe all
/// come through the same painter a drive goes through, and a test asserts
/// the position is a winnable field at its par.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onByre = true});

  /// Whether to draw the byre boards behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onByre;

  static Play get standing => Play.of(Fields.at(1));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onByre)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.byre,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.07),
                    child: CustomPaint(
                      painter: FieldView(
                        play: standing,
                        pointing: null,
                        showRungs: true,
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
