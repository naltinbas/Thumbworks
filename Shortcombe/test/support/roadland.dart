import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shortcombe/road/levels.dart';
import 'package:shortcombe/ui/app.dart';
import 'package:shortcombe/ui/road_screen.dart';
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
  await tester.pumpWidget(const ShortcombeApp());
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

RoadScreenState state(WidgetTester tester) =>
    tester.state<RoadScreenState>(find.byType(RoadScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns the crowd dial one step, two hundred, [by] 1 or -1.
Future<void> turn(WidgetTester tester, int by) async {
  await tester.tap(find.byKey(Key('crowd${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Opens or shuts the shortcut.
Future<void> toggle(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('shortcut')));
  await tester.pumpAndSettle();
}

/// Sets the crowd and the shortcut from where they stand, a step a
/// tap, the crowd first.
Future<void> setDials(WidgetTester tester, int crowd, bool open) async {
  while (state(tester).play.crowd != crowd && !state(tester).play.isOver) {
    await turn(tester, (crowd - state(tester).play.crowd).sign);
  }
  if (state(tester).play.open != open && !state(tester).play.isOver) {
    await toggle(tester);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  if (which == 0) {
    await turn(tester, by);
  } else {
    await toggle(tester);
  }
}

/// Follows the pointer until the setting lands, [most] steps at most.
Future<void> settleByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
