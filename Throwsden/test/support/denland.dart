import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:throwsden/fair/levels.dart';
import 'package:throwsden/ui/app.dart';
import 'package:throwsden/ui/yard_screen.dart';
import 'package:throwsden/ui/yardview.dart';
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
  await tester.pumpWidget(const ThrowsdenApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
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

/// Taps a wrestler where he stands, bench or line, through the
/// painter's metrics.
Future<void> tapWrestler(WidgetTester tester, int w) async {
  final room = board(tester);
  final play = state(tester).play;
  final metrics = Metrics(play, room.size);
  final at = play.line.contains(w) ? metrics.slotAt(play.line.indexOf(w)) : metrics.benchAt(w);
  await tester.tapAt(room.topLeft + at);
  await tester.pumpAndSettle();
}

/// Steps wrestlers in one after another.
Future<void> stepAll(WidgetTester tester, List<int> wrestlers) async {
  for (final w in wrestlers) {
    await tapWrestler(tester, w);
  }
}

/// Lines up by the pointer until the yard lands.
Future<void> lineByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    final (_, w) = state(tester).pointing!;
    await tapWrestler(tester, w);
  }
}
