import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitrewick/board/levels.dart';
import 'package:mitrewick/board/rules.dart';
import 'package:mitrewick/ui/app.dart';
import 'package:mitrewick/ui/board_screen.dart';
import 'package:mitrewick/ui/boardview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a board, or on the sham when [which] is null.
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
  await tester.pumpWidget(const MitrewickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a square through the painter's metrics.
Future<void> tapSquare(WidgetTester tester, Square square) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(square));
  await tester.pumpAndSettle();
}

/// Sets bishops one after another.
Future<void> setAll(WidgetTester tester, List<Square> squares) async {
  for (final square in squares) {
    await tapSquare(tester, square);
  }
}

/// Sets by the pointer until the board lands.
Future<void> setByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, square) = state(tester).pointing!;
    await tapSquare(tester, square);
  }
}
