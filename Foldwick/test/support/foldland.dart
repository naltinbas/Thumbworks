import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldwick/plank/crossings.dart';
import 'package:foldwick/ui/app.dart';
import 'package:foldwick/ui/plank_screen.dart';
import 'package:foldwick/ui/plankview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a crossing, or on the sham when [which] is null.
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
  await tester.pumpWidget(const FoldwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Crossings.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

PlankScreenState state(WidgetTester tester) =>
    tester.state<PlankScreenState>(find.byType(PlankScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a pen through the painter's metrics.
Future<void> tapPen(WidgetTester tester, int pen) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(pen));
  await tester.pumpAndSettle();
}

/// Moves the beasts in the pens given, in turn.
Future<void> moveAll(WidgetTester tester, List<int> pens) async {
  for (final pen in pens) {
    await tapPen(tester, pen);
  }
}

/// Crosses by the pointer until the beasts have changed ends.
Future<void> crossByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    await tapPen(tester, state(tester).pointing!);
  }
}
