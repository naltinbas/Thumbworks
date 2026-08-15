import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slateford/slate/levels.dart';
import 'package:slateford/slate/rules.dart';
import 'package:slateford/ui/app.dart';
import 'package:slateford/ui/slate_screen.dart';
import 'package:slateford/ui/slateview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a level, or on the sham when [which] is null.
Future<void> open(
  WidgetTester tester, {
  int? which,
  Size? screen,
}) async {
  SharedPreferences.setMockInitialValues({});
  if (screen != null) {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(const SlatefordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

SlateScreenState state(WidgetTester tester) =>
    tester.state<SlateScreenState>(find.byType(SlateScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cell through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int cell) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(cell));
  await tester.pumpAndSettle();
}

/// Marks cells one after another; the book answers each.
Future<void> markAll(WidgetTester tester, List<int> cells) async {
  for (final cell in cells) {
    await tapCell(tester, cell);
  }
}

/// Plays by the pointer until the slate is over.
Future<void> playByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 6) {
    await press(tester, 'Show me');
    final cell = state(tester).pointing!;
    await tapCell(tester, cell);
  }
}

/// Fills the slate from the first empty cell on, until it is over.
Future<void> fillIn(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 6) {
    final cell = Rules.empties(state(tester).play.board).first;
    await tapCell(tester, cell);
  }
}

/// Plays the hopeless slate out level: the tree's best moves, which
/// on a level slate keep it level, by the rules directly since the
/// pointer keeps quiet on a hopeless level.
Future<void> playByPointerOrFill(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 6) {
    final cell = Rules.bestMoves(state(tester).play.board).first;
    await tapCell(tester, cell);
  }
}
