import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halvingham/ledger/levels.dart';
import 'package:halvingham/ui/app.dart';
import 'package:halvingham/ui/ledger_screen.dart';
import 'package:halvingham/ui/ledgerview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a ledger, or on the sham when [which] is null.
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
  await tester.pumpWidget(const HalvinghamApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

LedgerScreenState state(WidgetTester tester) =>
    tester.state<LedgerScreenState>(find.byType(LedgerScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a row through the painter's metrics.
Future<void> tapRow(WidgetTester tester, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(c));
  await tester.pumpAndSettle();
}

/// Taps rows one after another.
Future<void> tapAll(WidgetTester tester, List<int> rows) async {
  for (final c in rows) {
    await tapRow(tester, c);
  }
}

/// Keeps every row as the pointer says.
Future<void> keepByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (_, c) = state(tester).pointing!;
    await tapRow(tester, c);
  }
}
