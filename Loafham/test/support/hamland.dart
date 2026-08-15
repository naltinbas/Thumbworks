import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafham/loaf/loaves.dart';
import 'package:loafham/ui/app.dart';
import 'package:loafham/ui/loaf_screen.dart';
import 'package:loafham/ui/loafview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a share, or on the sham when [which] is null.
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
  await tester.pumpWidget(const LoafhamApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Loaves.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

LoafScreenState state(WidgetTester tester) =>
    tester.state<LoafScreenState>(find.byType(LoafScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cut's tile through the painter's metrics.
Future<void> tapCut(WidgetTester tester, int den) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.tileAt(den));
  await tester.pumpAndSettle();
}

/// Takes cuts one after another.
Future<void> takeAll(WidgetTester tester, List<int> dens) async {
  for (final den in dens) {
    await tapCut(tester, den);
  }
}

/// Cuts by the pointer until the share is made.
Future<void> cutByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, den) = state(tester).pointing!;
    await tapCut(tester, den);
  }
}
