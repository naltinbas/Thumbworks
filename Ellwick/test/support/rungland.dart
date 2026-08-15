import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ellwick/rung/levels.dart';
import 'package:ellwick/ui/app.dart';
import 'package:ellwick/ui/rung_screen.dart';
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
  await tester.pumpWidget(const EllwickApp());
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

RungScreenState state(WidgetTester tester) =>
    tester.state<RungScreenState>(find.byType(RungScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'side' or 'diagonal', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Climbs the ladder a rung.
Future<void> climb(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('climb')));
  await tester.pumpAndSettle();
}

/// Sets the side and the diagonal from where they stand, a step a tap,
/// the side first.
Future<void> setDials(WidgetTester tester, int side, int diagonal) async {
  while (state(tester).play.side != side && !state(tester).play.isOver) {
    await turn(tester, 'side', (side - state(tester).play.side).sign);
  }
  while (state(tester).play.diagonal != diagonal && !state(tester).play.isOver) {
    await turn(tester, 'diagonal', (diagonal - state(tester).play.diagonal).sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  if (which == 2) {
    await climb(tester);
  } else {
    await turn(tester, which == 0 ? 'side' : 'diagonal', by);
  }
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> measureByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
