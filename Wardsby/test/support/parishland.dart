import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardsby/parish/levels.dart';
import 'package:wardsby/ui/app.dart';
import 'package:wardsby/ui/parish_screen.dart';
import 'package:wardsby/ui/parishview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const WardsbyApp());
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

ParishScreenState state(WidgetTester tester) =>
    tester.state<ParishScreenState>(find.byType(ParishScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps household [c] through the painter's metrics.
Future<void> tapHouse(WidgetTester tester, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cellAt(c));
  await tester.pumpAndSettle();
}

/// Taps household [c] until it sits in ward [w].
Future<void> setWard(WidgetTester tester, int c, int w) async {
  var guard = 0;
  while (state(tester).play.wards[c] != w && guard++ < 7) {
    await tapHouse(tester, c);
  }
}

/// Draws a whole parish, ward numbers in reading order.
Future<void> draw(WidgetTester tester, List<int> wards) async {
  for (var c = 0; c < wards.length && !state(tester).play.isOver; c++) {
    await setWard(tester, c, wards[c]);
  }
}

/// Does what the pointer says, once: taps the ringed household as many
/// times as it says.
Future<void> tapByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (c, taps) = state(tester).pointing!;
  for (var k = 0; k < taps; k++) {
    await tapHouse(tester, c);
  }
}

/// Follows the pointer until the parish is drawn as asked.
Future<void> drawByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await tapByPointer(tester);
  }
}
