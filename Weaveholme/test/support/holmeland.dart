import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weaveholme/plaid/levels.dart';
import 'package:weaveholme/ui/app.dart';
import 'package:weaveholme/ui/plaid_screen.dart';
import 'package:weaveholme/ui/plaidview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a plaid, or on the sham when [which] is null.
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
  await tester.pumpWidget(const WeaveholmeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few plaids only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

PlaidScreenState state(WidgetTester tester) =>
    tester.state<PlaidScreenState>(find.byType(PlaidScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the square at row [r], column [c] through the painter's metrics.
Future<void> tapSquare(WidgetTester tester, int r, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(r, c));
  await tester.pumpAndSettle();
}

/// Taps squares one after another.
Future<void> tapAll(WidgetTester tester, List<(int, int)> squares) async {
  for (final (r, c) in squares) {
    await tapSquare(tester, r, c);
  }
}

/// Weaves the plaid as the pointer says.
Future<void> weaveByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (r, c) = state(tester).pointing!;
    await tapSquare(tester, r, c);
  }
}
