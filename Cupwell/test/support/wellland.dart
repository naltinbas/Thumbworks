import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupwell/tray/levels.dart';
import 'package:cupwell/ui/app.dart';
import 'package:cupwell/ui/tray_screen.dart';
import 'package:cupwell/ui/trayview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a tray, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CupwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

TrayScreenState state(WidgetTester tester) =>
    tester.state<TrayScreenState>(find.byType(TrayScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cup through the painter's metrics.
Future<void> tapCup(WidgetTester tester, int cup) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(cup));
  await tester.pumpAndSettle();
}

/// Taps cups one after another.
Future<void> tapAll(WidgetTester tester, List<int> cups) async {
  for (final c in cups) {
    await tapCup(tester, c);
  }
}

/// Rights the tray by the pointer.
Future<void> rightByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 30) {
    await press(tester, 'Show me');
    final (_, cup) = state(tester).pointing!;
    await tapCup(tester, cup);
  }
}
