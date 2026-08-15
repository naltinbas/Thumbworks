import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:copperwick/coins/levels.dart';
import 'package:copperwick/coins/rules.dart';
import 'package:copperwick/ui/app.dart';
import 'package:copperwick/ui/table_screen.dart';
import 'package:copperwick/ui/tableview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a triangle, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CopperwickApp());
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

TableScreenState state(WidgetTester tester) =>
    tester.state<TableScreenState>(find.byType(TableScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a spot through the painter's metrics.
Future<void> tapSpot(WidgetTester tester, Spot s) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(s));
  await tester.pumpAndSettle();
}

/// Taps spots one after another.
Future<void> tapAll(WidgetTester tester, List<Spot> spots) async {
  for (final s in spots) {
    await tapSpot(tester, s);
  }
}

/// Turns the triangle as the pointer says.
Future<void> turnByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 30) {
    await press(tester, 'Show me');
    final (_, s) = state(tester).pointing!;
    await tapSpot(tester, s);
  }
}
