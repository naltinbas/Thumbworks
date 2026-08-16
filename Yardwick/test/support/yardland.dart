import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yardwick/yard/levels.dart';
import 'package:yardwick/ui/app.dart';
import 'package:yardwick/ui/yard_screen.dart';
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
  await tester.pumpWidget(const YardwickApp());
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

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps [which], 'm' or 'n', by one, up or down, on its dial.
Future<void> turn(WidgetTester tester, String which, int by) async {
  await tester.tap(find.byKey(Key('$which${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Steps the dials to the counts (m, n), the first then the second;
/// stops if the ask ends first.
Future<void> setCounts(WidgetTester tester, int m, int n) async {
  Future<void> run(String which, int Function() now, int want) async {
    while (now() != want && !state(tester).play.isOver) {
      await turn(tester, which, want > now() ? 1 : -1);
    }
  }

  await run('m', () => state(tester).play.first, m);
  await run('n', () => state(tester).play.second, n);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which, by);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> countsByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
