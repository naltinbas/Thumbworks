import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thornguard/game/board.dart';
import 'package:thornguard/ui/board_painter.dart';
import 'package:thornguard/ui/board_view.dart';

/// The bits every test that touches the board needs.

BoardView boardView(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView));

Board board(WidgetTester tester) => boardView(tester).board;

/// Where the board thinks a square is.
///
/// Asked of the painter rather than worked out again here, so a tap lands on
/// the square the game is drawing. A test with its own copy of the geometry
/// keeps passing while the board drifts under the thumb.
Metrics metricsOf(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.descendant(
      of: find.byType(BoardView),
      matching: find.byType(CustomPaint),
    ))
    .map((paint) => paint.painter)
    .whereType<BoardPainter>()
    .first
    .metrics;

Offset squareAt(WidgetTester tester, Square at) =>
    tester.getTopLeft(find.byType(BoardView)) +
    metricsOf(tester).squareAt(at).center;

Future<void> tapSquare(WidgetTester tester, Square at) async {
  await tester.tapAt(squareAt(tester, at));
  await tester.pump();
}
