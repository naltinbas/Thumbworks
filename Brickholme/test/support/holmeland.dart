import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brickholme/yard/levels.dart';
import 'package:brickholme/ui/app.dart';
import 'package:brickholme/ui/yard_screen.dart';
import 'package:brickholme/ui/yardview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a yard, or on the sham when [which] is null.
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
  await tester.pumpWidget(const BrickholmeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few yards only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a flag through the painter's metrics.
Future<void> tapFlag(WidgetTester tester, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(c));
  await tester.pumpAndSettle();
}

/// Taps flags one after another.
Future<void> tapAll(WidgetTester tester, List<int> flags) async {
  for (final c in flags) {
    await tapFlag(tester, c);
  }
}

/// Faces the yard across or down, through the button.
Future<void> face(WidgetTester tester, bool across) async {
  if (state(tester).play.across != across) {
    await press(tester, across ? 'Bricks down' : 'Bricks across');
  }
}

/// Paves the yard as the pointer says.
Future<void> paveByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (_, brick) = state(tester).pointing!;
    await tapFlag(tester, brick.$1);
  }
}

/// Lays the first brick that fits, again and again, until none does.
Future<void> layUntilStuck(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 40) {
    final brick = state(tester).play.openings.first;
    await face(tester, brick.$2);
    await tapFlag(tester, brick.$1);
  }
}
