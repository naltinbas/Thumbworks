import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hustingsby/poll/levels.dart';
import 'package:hustingsby/ui/app.dart';
import 'package:hustingsby/ui/poll_screen.dart';
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
  await tester.pumpWidget(const HustingsbyApp());
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

PollScreenState state(WidgetTester tester) =>
    tester.state<PollScreenState>(find.byType(PollScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Draws an Ash ballot ([ash] true) or a Birch one.
Future<void> draw(WidgetTester tester, bool ash) async {
  await tester.tap(find.byKey(Key(ash ? 'ash' : 'birch')));
  await tester.pumpAndSettle();
}

/// Draws the ballots of [order] in turn.
Future<void> drawAll(WidgetTester tester, List<bool> order) async {
  for (final a in order) {
    await draw(tester, a);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final by = state(tester).pointing!;
  if (by == 2) {
    await press(tester, 'Back');
  } else {
    await draw(tester, by == 0);
  }
}

/// Follows the pointer until the count lands, [most] steps at most.
Future<void> countByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
