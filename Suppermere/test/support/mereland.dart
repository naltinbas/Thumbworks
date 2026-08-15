import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suppermere/hall/levels.dart';
import 'package:suppermere/ui/app.dart';
import 'package:suppermere/ui/hall_screen.dart';
import 'package:suppermere/ui/hallview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a supper, or on the sham when [which] is null.
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
  await tester.pumpWidget(const SuppermereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

HallScreenState state(WidgetTester tester) =>
    tester.state<HallScreenState>(find.byType(HallScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a guest through the painter's metrics.
Future<void> tapGuest(WidgetTester tester, int g) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(g));
  await tester.pumpAndSettle();
}

/// Taps guests one after another.
Future<void> tapAll(WidgetTester tester, List<int> guests) async {
  for (final g in guests) {
    await tapGuest(tester, g);
  }
}

/// Seats every guest as the pointer says.
Future<void> seatByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 30) {
    await press(tester, 'Show me');
    final (_, g) = state(tester).pointing!;
    await tapGuest(tester, g);
  }
}
