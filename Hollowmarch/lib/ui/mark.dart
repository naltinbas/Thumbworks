import 'package:flutter/material.dart';

import '../pegs/boards.dart';
import '../pegs/play.dart';
import 'hollows.dart';
import 'palette.dart';

/// The mark: a small cross of hollows, part way through a game.
///
/// It is not a drawing of the game, it is the game — a board taken four
/// jumps down through the same code a finger goes through and drawn by the
/// painter the screen uses. The peg on the move is the green one, which is
/// the one thing worth showing about this game in a picture: a peg has just
/// taken something and can take again.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onWood = true});

  /// Whether to draw the wood behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onWood;

  static const board = Board(
    name: 'mark',
    rows: ['#...#', '#...#', '.....', '#...#', '#...#'],
    empty: (2, 1),
  );

  /// The board three jumps into the fewest way through it, with the last peg
  /// still on the move and able to take again.
  static Play get part {
    final field = board.field;
    var play = Play.of(board);
    for (final (from, to) in const [
      ((0, 1), (2, 1)),
      ((3, 1), (1, 1)),
      ((2, 3), (2, 1)),
    ]) {
      play = play.letGo.jump(
        field.at(from.$1, from.$2),
        field.at(to.$1, to.$2),
      );
    }
    return play;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final side = room.biggest.shortestSide;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onWood)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.wood,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.08),
                    child: CustomPaint(
                      painter: Hollows(
                        play: part,
                        holding: -1,
                        pointing: const [],
                        wrong: false,
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
