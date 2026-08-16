import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubbleford/kiss/levels.dart';
import 'package:bubbleford/ui/app.dart';
import 'package:bubbleford/ui/kiss_screen.dart';
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
  await tester.pumpWidget(const BubblefordApp());
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

KissScreenState state(WidgetTester tester) =>
    tester.state<KissScreenState>(find.byType(KissScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps the dial at [place], 0 to 2, up or down by one.
Future<void> turn(WidgetTester tester, int place, int by) async {
  await tester.tap(find.byKey(Key('k$place${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Steps the dials to [bends], each in turn; stops if the ask ends.
Future<void> setBends(WidgetTester tester, List<int> bends) async {
  for (var i = 0; i < 3; i++) {
    while (!state(tester).play.isOver && state(tester).play.bends[i] != bends[i]) {
      await turn(tester, i, bends[i] > state(tester).play.bends[i] ? 1 : -1);
    }
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (place, by) = state(tester).pointing!;
  await turn(tester, place, by);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> bendsByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
