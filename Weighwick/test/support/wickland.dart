import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighwick/scale/levels.dart';
import 'package:weighwick/ui/app.dart';
import 'package:weighwick/ui/scale_screen.dart';
import 'package:weighwick/ui/scaleview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a load, or on the sham when [which] is null.
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
  await tester.pumpWidget(const WeighwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

ScaleScreenState state(WidgetTester tester) =>
    tester.state<ScaleScreenState>(find.byType(ScaleScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps weight [i] where it stands, through the painter's metrics.
Future<void> tapWeight(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(i));
  await tester.pumpAndSettle();
}

/// Taps weights one after another.
Future<void> moveAll(WidgetTester tester, List<int> weights) async {
  for (final i in weights) {
    await tapWeight(tester, i);
  }
}

/// Moves by the pointer until the scale is level.
Future<void> moveByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, i) = state(tester).pointing!;
    await tapWeight(tester, i);
  }
}
