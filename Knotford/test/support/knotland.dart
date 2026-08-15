import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knotford/rope/ropes.dart';
import 'package:knotford/ui/app.dart';
import 'package:knotford/ui/rope_screen.dart';
import 'package:knotford/ui/ropeview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a rope, or on the sham when [which] is null.
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
  await tester.pumpWidget(const KnotfordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Ropes.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

RopeScreenState state(WidgetTester tester) =>
    tester.state<RopeScreenState>(find.byType(RopeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a knot through the painter's metrics.
Future<void> tapKnot(WidgetTester tester, int knot) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(knot));
  await tester.pumpAndSettle();
}

/// Stands pegs one after another.
Future<void> standAll(WidgetTester tester, List<int> knots) async {
  for (final knot in knots) {
    await tapKnot(tester, knot);
  }
}

/// Stands pegs by the pointer until the corner is square.
Future<void> standByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 8) {
    await press(tester, 'Show me');
    final (_, knot) = state(tester).pointing!;
    await tapKnot(tester, knot);
  }
}
