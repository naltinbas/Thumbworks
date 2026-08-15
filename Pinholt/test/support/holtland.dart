import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinholt/board/plots.dart';
import 'package:pinholt/board/rules.dart';
import 'package:pinholt/ui/app.dart';
import 'package:pinholt/ui/board_screen.dart';
import 'package:pinholt/ui/boardview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a plot, or on the sham when [which] is null.
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
  await tester.pumpWidget(const PinholtApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Plots.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a hole through the painter's metrics.
Future<void> tapHole(WidgetTester tester, Hole hole) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(hole));
  await tester.pumpAndSettle();
}

/// Sets pins one after another.
Future<void> setPins(WidgetTester tester, List<Hole> holes) async {
  for (final hole in holes) {
    await tapHole(tester, hole);
  }
}

/// Sets by the pointer until the plot lands.
Future<void> setByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (_, hole) = state(tester).pointing!;
    await tapHole(tester, hole);
  }
}
