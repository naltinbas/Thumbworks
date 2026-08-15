import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threadwick/star/levels.dart';
import 'package:threadwick/ui/app.dart';
import 'package:threadwick/ui/star_screen.dart';
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
  await tester.pumpWidget(const ThreadwickApp());
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

StarScreenState state(WidgetTester tester) =>
    tester.state<StarScreenState>(find.byType(StarScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'nails' or 'skip', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Turns the dials from where they stand to [nails] and [skip], a step
/// a tap, the nails first.
Future<void> setDials(WidgetTester tester, int nails, int skip) async {
  while (state(tester).play.nails != nails && !state(tester).play.isOver) {
    await turn(tester, 'nails', (nails - state(tester).play.nails).sign);
  }
  while (state(tester).play.skip != skip && !state(tester).play.isOver) {
    await turn(tester, 'skip', (skip - state(tester).play.skip).sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which == 0 ? 'nails' : 'skip', by);
}

/// Follows the pointer until the star lands, [most] steps at most.
Future<void> threadByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
