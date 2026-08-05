import 'package:flutter/material.dart';

import '../board/pieces.dart';
import 'man.dart';
import 'palette.dart';

/// The mark: two squares of a board, and a knight on the light one.
///
/// The whole game in two shapes, and it reads at forty eight points — which
/// is the size that decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onBoard = true});

  /// Whether to draw the board behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onBoard;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;
          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onBoard)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.board,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: side * 0.62,
                      height: side * 0.62,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _Square(side: side * 0.31, pale: true),
                              _Square(side: side * 0.31, pale: false),
                            ],
                          ),
                          Row(
                            children: [
                              _Square(side: side * 0.31, pale: false),
                              _Square(
                                side: side * 0.31,
                                pale: true,
                                piece: Piece.knight,
                              ),
                            ],
                          ),
                        ],
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

class _Square extends StatelessWidget {
  const _Square({required this.side, required this.pale, this.piece});

  final double side;
  final bool pale;
  final Piece? piece;

  @override
  Widget build(BuildContext context) => Container(
        width: side,
        height: side,
        color: pale ? Palette.light : Palette.dark,
        alignment: Alignment.center,
        child: piece == null ? null : Man(piece: piece!, side: side * 0.78),
      );
}
