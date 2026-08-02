import 'package:flutter/material.dart' hide Card, Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:fanwright/game/game.dart';
import 'package:fanwright/game/table.dart';
import 'package:fanwright/ui/app.dart';
import 'package:fanwright/ui/game_screen.dart';
import 'package:fanwright/ui/table_painter.dart';

/// The bits every test that touches the table needs.

/// A phone to lay the game out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  Game? at,
  bool playing = true,
  int place = 0,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(FanwrightApp(
    place: place,
    opensPlaying: playing,
    opening: at,
  ));
  await tester.pump();
}

GameScreenState screenState(WidgetTester tester) =>
    tester.state<GameScreenState>(find.byType(GameScreen));

Table table(WidgetTester tester) => screenState(tester).game.table;

Finder tablePaint() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is TablePainter,
    );

TablePainter painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(tablePaint().first).painter! as TablePainter;

/// Where the table thinks something is.
///
/// Read off the painter rather than worked out again, so a tap lands on the
/// card the game is drawing. On a board of fifty two overlapping cards that is
/// not a nicety.
Metrics metricsOf(WidgetTester tester) => painterOf(tester).metrics;

Offset _origin(WidgetTester tester) => tester.getTopLeft(tablePaint().first);

/// Taps a card in a column, counting from the top of the pile. Without
/// [card], the one on the end.
Future<void> tapColumn(WidgetTester tester, int at, {int? card}) async {
  final metrics = metricsOf(tester);
  final column = table(tester).column(at);
  final which = card ?? (column.isEmpty ? 0 : column.length - 1);
  final step = metrics.stepFor(column.length);
  final box = Rect.fromLTWH(
    metrics.gap + at * (metrics.cardWidth + metrics.gap),
    metrics.columnsTop + which * step,
    metrics.cardWidth,
    // Only the strip of the card that is not covered by the next one is
    // actually tappable, so aim at that rather than at the middle.
    which == column.length - 1 || column.isEmpty ? metrics.cardHeight : step,
  );
  await tester.tapAt(_origin(tester) + box.center);
  await tester.pump();
}

Future<void> tapCell(WidgetTester tester, int at) async {
  await tester.tapAt(_origin(tester) + metricsOf(tester).cellAt(at).center);
  await tester.pump();
}

/// Waits for the solver, which runs on another thread.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 300; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 20));
    if (!screenState(tester).thinking) return;
  }
}

/// A position with no move in it at all: every column topped by a black card
/// and every cell holding one, so nothing can sit anywhere, and no ace loose.
final stuckTable = Table.of(
  columns: const [
    '3H 2S',
    '4H 3S',
    '5H 4S',
    '6H 5S',
    '7H 6S',
    '8H 7S',
    '9H 8S',
    'TH 9S',
  ],
  cells: const ['TS', 'JS', 'QS', 'KS'],
);
