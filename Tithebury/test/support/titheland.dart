import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tithebury/tithe/levels.dart';
import 'package:tithebury/ui/app.dart';
import 'package:tithebury/ui/tithe_screen.dart';
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
  await tester.pumpWidget(const TitheburyApp());
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

TitheScreenState state(WidgetTester tester) =>
    tester.state<TitheScreenState>(find.byType(TitheScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Winds the dial by [by]: -10, -1, 1 or 10.
Future<void> wind(WidgetTester tester, int by) async {
  await tester.tap(find.byKey(Key('wind${by > 0 ? '+' : ''}$by')));
  await tester.pumpAndSettle();
}

/// Winds the dial from where it stands to [number], tens then ones.
Future<void> setNumber(WidgetTester tester, int number) async {
  while (state(tester).play.number != number && !state(tester).play.isOver) {
    final gap = number - state(tester).play.number;
    await wind(tester, gap.abs() >= 10 ? gap.sign * 10 : gap.sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await wind(tester, state(tester).pointing!);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> tallyByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
