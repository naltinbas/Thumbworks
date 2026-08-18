import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokemere/yoke/levels.dart';
import 'package:yokemere/ui/app.dart';
import 'package:yokemere/ui/yoke_screen.dart';
import 'package:yokemere/ui/yokeview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the yard when [which] is null.
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
  await tester.pumpWidget(const YokemereApp());
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

YokeScreenState state(WidgetTester tester) =>
    tester.state<YokeScreenState>(find.byType(YokeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a place of the team is, which is where a thumb goes.
Offset placeAt(WidgetTester tester, int place) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).offAt(place);
}

/// A point above the near row, which is no place at all.
Offset skyAt(WidgetTester tester) {
  final where = board(tester);
  return where.topLeft + Offset(where.width / 2, 4);
}

/// Taps a place, which takes hold of it or changes it over.
Future<void> tapPlace(WidgetTester tester, int place) async {
  await tester.tapAt(placeAt(tester, place));
  await tester.pumpAndSettle();
}

/// Changes two places over, which is two taps.
Future<void> swap(WidgetTester tester, int one, int two) async {
  await tapPlace(tester, one);
  await tapPlace(tester, two);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).play.next!;
  await swap(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] swaps at most.
Future<void> yokeByPointer(WidgetTester tester, {int most = 10}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
