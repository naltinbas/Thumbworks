import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capwick/line/levels.dart';
import 'package:capwick/line/rules.dart';
import 'package:capwick/ui/app.dart';
import 'package:capwick/ui/line_screen.dart';
import 'package:capwick/ui/lineview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a line, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CapwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

LineScreenState state(WidgetTester tester) =>
    tester.state<LineScreenState>(find.byType(LineScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Calls black or white for the current man through the painter's
/// metrics.
Future<void> call(WidgetTester tester, bool black) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + (black ? metrics.blackAt : metrics.whiteAt));
  await tester.pumpAndSettle();
}

/// Calls down the line, one call per man.
Future<void> callAll(WidgetTester tester, List<bool> calls) async {
  for (final c in calls) {
    await call(tester, c);
  }
}

/// Calls the plan down the whole line.
Future<void> callThePlan(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.allCalled && guard++ < 8) {
    final play = state(tester).play;
    await call(tester, Rules.planCall(play.caps, play.current, play.calls));
  }
}

/// Calls by the pointer until the line is over.
Future<void> callByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 8) {
    await press(tester, 'Show me');
    final (what, _) = state(tester).pointing!;
    await call(tester, what == 'black');
  }
}
