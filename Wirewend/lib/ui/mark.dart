import 'package:flutter/material.dart';

import '../game/grid.dart';
import 'cell_painter.dart';
import 'palette.dart';

/// The mark: four cells of a solved board, with the current running from the
/// source into the lamp.
///
/// It is not a drawing of the game — it is the game's own cell painter, given
/// four cells that really do join up, so the wire in the logo obeys the same
/// rule the board does. The whole idea of the game in one picture: a line of
/// current, and a lamp at the end of it that is on because of it.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onPanel = true});

  /// Whether to draw the panel behind it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onPanel;

  /// Two by two: the source bottom left, a corner above it, a corner beside
  /// that, and the lamp under it. Current runs the whole way round.
  static List<Cell> get cells => [
    // Top left: a corner joining east and south.
    Cell(kind: CellKind.wire, ends: Ends.east | Ends.south),
    // Top right: a corner joining west and south.
    Cell(kind: CellKind.wire, ends: Ends.west | Ends.south),
    // Bottom left: the source, reaching north.
    Cell(kind: CellKind.source, ends: Ends.north),
    // Bottom right: the lamp, reaching north.
    Cell(kind: CellKind.lamp, ends: Ends.north),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;
          final cell = side * 0.42;
          final four = cells;

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
                for (var i = 0; i < four.length; i++)
                  Positioned(
                    left: side * 0.08 + (i % 2) * cell,
                    top: side * 0.08 + (i ~/ 2) * cell,
                    child: SizedBox(
                      width: cell,
                      height: cell,
                      child: CustomPaint(
                        painter: CellPainter(
                          cell: four[i],
                          lit: 1,
                          spin: 1,
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
