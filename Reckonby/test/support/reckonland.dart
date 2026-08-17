import 'package:reckonby/count/levels.dart';
import 'package:reckonby/ui/wheel_screen.dart';
import 'package:reckonby/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  await tester.pumpWidget(const ReckonbyApp());
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

WheelScreenState state(WidgetTester tester) =>
    tester.state<WheelScreenState>(find.byType(WheelScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns one wheel: [wheel] counted from 1, [by] 1 or -1.
Future<void> turn(WidgetTester tester, int wheel, int by) async {
  await tester.tap(find.byKey(Key('$wheel!${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Walks the wheels to a reading, a notch a tap.
Future<void> setWheels(WidgetTester tester, List<int> want,
    {int most = 40}) async {
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver) return;
    var wheel = 0;
    for (var i = 1; i <= want.length; i++) {
      if (was.wheels[i - 1] != want[i - 1]) {
        wheel = i;
        break;
      }
    }
    if (wheel == 0) return;
    await turn(tester, wheel,
        was.wheels[wheel - 1] < want[wheel - 1] ? 1 : -1);
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (wheel, by) = state(tester).pointing!;
  await turn(tester, wheel, by);
}

/// Follows the pointer until the house reads as asked, [most] turns at
/// most.
Future<void> readByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
