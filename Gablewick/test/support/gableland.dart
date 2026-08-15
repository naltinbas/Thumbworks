import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gablewick/gable/levels.dart';
import 'package:gablewick/ui/app.dart';
import 'package:gablewick/ui/gable_screen.dart';
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
  await tester.pumpWidget(const GablewickApp());
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

GableScreenState state(WidgetTester tester) =>
    tester.state<GableScreenState>(find.byType(GableScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'first', 'second' or 'third', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Sets the three sides from where they stand, a step a tap, first
/// side first.
Future<void> setSides(WidgetTester tester, int a, int b, int c) async {
  const names = ['first', 'second', 'third'];
  final want = [a, b, c];
  for (var i = 0; i < 3; i++) {
    while (state(tester).play.sides[i] != want[i] && !state(tester).play.isOver) {
      await turn(tester, names[i], (want[i] - state(tester).play.sides[i]).sign);
    }
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, const ['first', 'second', 'third'][which], by);
}

/// Follows the pointer until the gable lands, [most] steps at most.
Future<void> frameByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
