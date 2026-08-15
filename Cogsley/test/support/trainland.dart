import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cogsley/train/levels.dart';
import 'package:cogsley/ui/app.dart';
import 'package:cogsley/ui/train_screen.dart';
import 'package:cogsley/ui/trainview.dart';
import 'package:cogsley/train/play.dart';
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
  await tester.pumpWidget(const CogsleyApp());
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

TrainScreenState state(WidgetTester tester) =>
    tester.state<TrainScreenState>(find.byType(TrainScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps peg (x, y) through the painter's metrics.
Future<void> tapPeg(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.peg(x, y));
  await tester.pumpAndSettle();
}

/// Taps tray slot [i].
Future<void> takeSlot(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.trayAt(i));
  await tester.pumpAndSettle();
}

/// Takes slot [i] and sets it on peg (x, y).
Future<void> setGear(WidgetTester tester, int i, int x, int y) async {
  await takeSlot(tester, i);
  await tapPeg(tester, x, y);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, a, b) = state(tester).pointing!;
  switch (aim) {
    case Aim.tray:
      await takeSlot(tester, a);
    case Aim.peg:
    case Aim.lift:
      await tapPeg(tester, a, b);
  }
}

/// Follows the pointer until the train lands, [most] steps at most.
Future<void> gearByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
