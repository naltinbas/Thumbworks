import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ninebury/nine/levels.dart';
import 'package:ninebury/ui/app.dart';
import 'package:ninebury/ui/nine_screen.dart';
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
  await tester.pumpWidget(const NineburyApp());
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

NineScreenState state(WidgetTester tester) =>
    tester.state<NineScreenState>(find.byType(NineScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'hundreds', 'tens' or 'units', [by]
/// 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Turns the dials from where they stand to [number], a step a tap,
/// the hundreds first unless [order] says otherwise.
Future<void> dial(WidgetTester tester, int number, {List<int> order = const [0, 1, 2]}) async {
  const names = ['hundreds', 'tens', 'units'];
  final want = [number ~/ 100 % 10, number ~/ 10 % 10, number % 10];
  for (final i in order) {
    while (state(tester).play.digits[i] != want[i] && !state(tester).play.isOver) {
      await turn(tester, names[i], (want[i] - state(tester).play.digits[i]).sign);
    }
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, ['hundreds', 'tens', 'units'][which], by);
}

/// Follows the pointer until the number lands, [most] steps at most.
Future<void> dialByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
