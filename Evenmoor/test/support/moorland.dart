import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evenmoor/moor/peggings.dart';
import 'package:evenmoor/moor/rules.dart';
import 'package:evenmoor/ui/app.dart';
import 'package:evenmoor/ui/moor_screen.dart';
import 'package:evenmoor/ui/moorview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a pegging, or on the sham when [which] is null.
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
  await tester.pumpWidget(const EvenmoorApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Peggings.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

MoorScreenState state(WidgetTester tester) =>
    tester.state<MoorScreenState>(find.byType(MoorScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a hole through the painter's metrics.
Future<void> tapHole(WidgetTester tester, Peg peg) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(peg));
  await tester.pumpAndSettle();
}

/// Sets pegs one after another.
Future<void> setPegs(WidgetTester tester, List<Peg> pegs) async {
  for (final peg in pegs) {
    await tapHole(tester, peg);
  }
}

/// Sets by the pointer until the pegging lands.
Future<void> setByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, peg) = state(tester).pointing!;
    await tapHole(tester, peg);
  }
}
