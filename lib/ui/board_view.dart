import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/grid.dart';
import 'palette.dart';
import 'wire_tile.dart';

/// The whole board, sized to whatever space it is given.
///
/// Tiles are square and the same size, and the grid takes the largest size
/// that still fits both ways, so a portrait phone never has to scroll to see
/// the puzzle. Nothing here decides a move: taps go back out to whoever owns
/// the board, which hands a new one down.
class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.board, this.onTapCell});

  final Board board;

  /// Null makes the board a picture rather than a game, which is what a
  /// finished level wants.
  final void Function(int row, int col)? onTapCell;

  /// Room between the grid and the panel edge, so the outermost wires do not
  /// run into the border.
  static const _panelPadding = 10.0;

  /// Used only when a parent gives the board no width to work with, which a
  /// phone screen never does.
  static const _fallbackTile = 56.0;

  /// The padding on both sides plus the thickest border on both sides, which
  /// is space the grid itself does not get.
  static const _frame = _panelPadding * 2 + 4;

  double _tileSide(BoxConstraints constraints) {
    final width = constraints.maxWidth - _frame;
    final height = constraints.maxHeight - _frame;
    final byWidth = width.isFinite ? width / board.cols : _fallbackTile;
    if (!height.isFinite) return byWidth;
    return math.max(1.0, math.min(byWidth, height / board.rows));
  }

  @override
  Widget build(BuildContext context) {
    // One walk of the board per frame rather than one per tile.
    final live = board.powered;
    final solved = board.isSolved;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _tileSide(constraints);
        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(_panelPadding),
            decoration: BoxDecoration(
              color: Palette.panel,
              borderRadius: BorderRadius.circular(side * 0.3),
              border: Border.all(
                color: solved ? Palette.solvedEdge : Palette.panelEdge,
                width: solved ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var row = 0; row < board.rows; row++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var col = 0; col < board.cols; col++)
                        SizedBox(
                          width: side,
                          height: side,
                          // Keyed by position so a tile keeps its state, and
                          // so its turn animation survives the new board a
                          // move produces.
                          child: WireTile(
                            key: ValueKey<int>(row * board.cols + col),
                            cell: board.at(row, col),
                            lit: live.contains(row * board.cols + col),
                            onTap: onTapCell == null || board.at(row, col).isEmpty
                                ? null
                                : () => onTapCell!(row, col),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
