import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabormere/drum/levels.dart';
import 'package:tabormere/drum/play.dart';
import 'package:tabormere/ui/app.dart';
import 'package:tabormere/ui/drum_screen.dart';
import 'package:tabormere/ui/drumview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const TabormereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

DrumScreenState state(WidgetTester tester) =>
    tester.state<DrumScreenState>(find.byType(DrumScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps step [i] through the painter's metrics.
Future<void> tapStep(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.step(i));
  await tester.pumpAndSettle();
}

/// Sets hits on every step of [steps], in turn.
Future<void> setAll(WidgetTester tester, List<int> steps) async {
  for (final s in steps) {
    await tapStep(tester, s);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, step) = state(tester).pointing!;
  switch (aim) {
    case Aim.set:
    case Aim.lift:
      await tapStep(tester, step);
  }
}

/// Follows the pointer until the rhythm lands, [most] steps at most.
Future<void> drumByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
