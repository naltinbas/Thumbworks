import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rowsworth/pebble/askings.dart';
import 'package:rowsworth/ui/app.dart';
import 'package:rowsworth/ui/rows_screen.dart';
import 'package:rowsworth/ui/rowsview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an asking, or on the sham when [which] is null.
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
  await tester.pumpWidget(const RowsworthApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Askings.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

RowsScreenState state(WidgetTester tester) =>
    tester.state<RowsScreenState>(find.byType(RowsScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a number through the painter's metrics.
Future<void> tapNumber(WidgetTester tester, int n) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cellAt(n));
  await tester.pumpAndSettle();
}

/// Picks by the pointer until the asking is met.
Future<void> pickByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 4) {
    await press(tester, 'Show me');
    await tapNumber(tester, state(tester).pointing!);
  }
}
