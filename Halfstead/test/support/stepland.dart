import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:halfstead/step/levels.dart';
import 'package:halfstead/ui/app.dart';
import 'package:halfstead/ui/step_screen.dart';
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
  await tester.pumpWidget(const HalfsteadApp());
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

StepScreenState state(WidgetTester tester) =>
    tester.state<StepScreenState>(find.byType(StepScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'share' or 'steps', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Turns the dials from where they stand to share [shareIndex] and
/// [steps] steps, a step a tap, the share first.
Future<void> setDials(WidgetTester tester, int shareIndex, int steps) async {
  while (state(tester).play.shareIndex != shareIndex && !state(tester).play.isOver) {
    await turn(tester, 'share', (shareIndex - state(tester).play.shareIndex).sign);
  }
  while (state(tester).play.steps != steps && !state(tester).play.isOver) {
    await turn(tester, 'steps', (steps - state(tester).play.steps).sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which == 0 ? 'share' : 'steps', by);
}

/// Follows the pointer until the run lands, [most] steps at most.
Future<void> runByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
