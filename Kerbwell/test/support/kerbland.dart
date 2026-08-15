import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerbwell/ui/app.dart';
import 'package:kerbwell/ui/yard_screen.dart';
import 'package:kerbwell/ui/yardview.dart';
import 'package:kerbwell/yard/rules.dart';
import 'package:kerbwell/yard/yards.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a yard, or on the sham when [which] is null.
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
  await tester.pumpWidget(const KerbwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Yards.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cell through the painter's metrics.
Future<void> tapCell(WidgetTester tester, Cell cell) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(cell));
  await tester.pumpAndSettle();
}

/// Lays slabs one after another.
Future<void> layAll(WidgetTester tester, List<Cell> cells) async {
  for (final cell in cells) {
    await tapCell(tester, cell);
  }
}

/// Lays by the pointer until the yard lands.
Future<void> layByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 24) {
    await press(tester, 'Show me');
    final (_, cell) = state(tester).pointing!;
    await tapCell(tester, cell);
  }
}
