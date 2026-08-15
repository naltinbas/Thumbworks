import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midford/peg/cordings.dart';
import 'package:midford/peg/rules.dart';
import 'package:midford/ui/app.dart';
import 'package:midford/ui/peg_screen.dart';
import 'package:midford/ui/pegview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a cording, or on the sham when [which] is null.
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
  await tester.pumpWidget(const MidfordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Cordings.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

PegScreenState state(WidgetTester tester) =>
    tester.state<PegScreenState>(find.byType(PegScreen));

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

/// Sets by the pointer until the cording lands.
Future<void> setByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, peg) = state(tester).pointing!;
    await tapHole(tester, peg);
  }
}
