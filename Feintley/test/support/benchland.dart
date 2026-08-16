import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feintley/feint/levels.dart';
import 'package:feintley/ui/app.dart';
import 'package:feintley/ui/feint_screen.dart';
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
  await tester.pumpWidget(const FeintleyApp());
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

FeintScreenState state(WidgetTester tester) =>
    tester.state<FeintScreenState>(find.byType(FeintScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps [which], 'n' or 'a', by [by], on its dial: the number by ten
/// or one, the base by one.
Future<void> turn(WidgetTester tester, String which, int by) async {
  await tester.tap(find.byKey(Key('$which${by > 0 ? '+' : ''}$by')));
  await tester.pumpAndSettle();
}

/// Steps the dials to the number [n] and the base [a], the number by
/// tens then ones; stops if the ask ends first.
Future<void> setTest(WidgetTester tester, int n, int a) async {
  while (!state(tester).play.isOver && (state(tester).play.number - n).abs() >= 10) {
    await turn(tester, 'n', state(tester).play.number < n ? 10 : -10);
  }
  while (!state(tester).play.isOver && state(tester).play.number != n) {
    await turn(tester, 'n', state(tester).play.number < n ? 1 : -1);
  }
  while (!state(tester).play.isOver && state(tester).play.base != a) {
    await turn(tester, 'a', state(tester).play.base < a ? 1 : -1);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which, by);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> testByPointer(WidgetTester tester, {int most = 200}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
