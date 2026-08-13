import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foursworth/ui/app.dart';
import 'package:foursworth/ui/window_screen.dart';
import 'package:foursworth/ui/windowview.dart';
import 'package:foursworth/window/houses.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a house, or on the worth when [which] is
/// null.
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
  await tester.pumpWidget(const FoursworthApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Houses.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

WindowScreenState state(WidgetTester tester) =>
    tester.state<WindowScreenState>(find.byType(WindowScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The worth board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a window through the painter's metrics.
Future<void> tapWindow(WidgetTester tester, int window) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.frameOf(window).center);
  await tester.pumpAndSettle();
}

/// Dials a window until it shows [face].
Future<void> dialTo(WidgetTester tester, int window, int face) async {
  var guard = 0;
  while (state(tester).play.windows[window] != face && guard++ < 9) {
    await tapWindow(tester, window);
  }
}

/// Dials by the pointer until the house lands.
Future<void> darkByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 30) {
    await press(tester, 'Show me');
    final window = state(tester).pointing!;
    await tapWindow(tester, window);
  }
}
