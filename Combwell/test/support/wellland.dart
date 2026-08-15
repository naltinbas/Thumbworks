import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:combwell/comb/levels.dart';
import 'package:combwell/ui/app.dart';
import 'package:combwell/ui/comb_screen.dart';
import 'package:combwell/ui/combview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a comb, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CombwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few combs only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

CombScreenState state(WidgetTester tester) =>
    tester.state<CombScreenState>(find.byType(CombScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cell through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(c));
  await tester.pumpAndSettle();
}

/// Puts a number in the picked cell through the pad.
Future<void> put(WidgetTester tester, int v) async {
  await tester.tap(find.widgetWithText(TextButton, '$v'));
  await tester.pumpAndSettle();
}

/// Fills a cell: picks it, then puts the number.
Future<void> fill(WidgetTester tester, int c, int v) async {
  await tapCell(tester, c);
  await put(tester, v);
}

/// Fills the comb as the pointer says.
Future<void> fillByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (what, c, v) = state(tester).pointing!;
    if (what == 'clear') {
      await tapCell(tester, c);
      continue;
    }
    await put(tester, v);
  }
}
