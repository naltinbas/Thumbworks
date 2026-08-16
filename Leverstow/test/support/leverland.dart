import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leverstow/lever/levels.dart';
import 'package:leverstow/ui/app.dart';
import 'package:leverstow/ui/lever_screen.dart';
import 'package:leverstow/ui/leverview.dart';
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
  await tester.pumpWidget(const LeverstowApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few asks only until it scrolls.
      await tester.scrollUntilVisible(tile, 80,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

LeverScreenState state(WidgetTester tester) =>
    tester.state<LeverScreenState>(find.byType(LeverScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> pressKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps slot [i] of the loop through the painter's metrics.
Future<void> tapSlot(WidgetTester tester, int i) async {
  final room = board(tester);
  await tester.tapAt(
      room.topLeft + Metrics(state(tester).play, room.size).at(i));
  await tester.pumpAndSettle();
}

/// Builds [loop] out of what is on the board, slot by slot.
Future<void> buildLoop(WidgetTester tester, String loop) async {
  while (!state(tester).play.isOver &&
      state(tester).play.loop.length > loop.length) {
    await pressKey(tester, 'shorter');
  }
  while (!state(tester).play.isOver &&
      state(tester).play.loop.length < loop.length) {
    await pressKey(tester, 'longer');
  }
  for (var i = 0; i < loop.length; i++) {
    if (state(tester).play.isOver) return;
    if (state(tester).play.loop[i] == loop[i]) continue;
    final was = state(tester).play.loop;
    await tapSlot(tester, i);
    if (state(tester).play.loop == was) return;
  }
}

/// Does what the pointer says, once.
Future<void> stepByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  switch (aim.$1) {
    case 'add':
      await pressKey(tester, 'longer');
    case 'drop':
      await pressKey(tester, 'shorter');
    default:
      await tapSlot(tester, aim.$2);
  }
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> loopByPointer(WidgetTester tester, {int most = 10}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await stepByPointer(tester);
  }
}
