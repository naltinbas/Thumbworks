import 'package:tosswell/toss/levels.dart';
import 'package:tosswell/ui/toss_screen.dart';
import 'package:tosswell/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:tosswell/ui/tossview.dart';
import 'package:flutter_test/flutter_test.dart';
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
  await tester.pumpWidget(const TosswellApp());
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

TossScreenState state(WidgetTester tester) =>
    tester.state<TossScreenState>(find.byType(TossScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a standing sits on the screen, which is where a thumb goes.
Offset standingAt(WidgetTester tester, (int, int) at) {
  final where = board(tester);
  return where.topLeft + Metrics(where.size).at(at);
}

/// Taps a standing, which marks it or takes the mark off.
Future<void> mark(WidgetTester tester, (int, int) at) async {
  await tester.tapAt(standingAt(tester, at));
  await tester.pumpAndSettle();
}

/// Marks a run of standings.
Future<void> markAll(WidgetTester tester, List<(int, int)> all) async {
  for (final at in all) {
    if (state(tester).play.isOver) return;
    await mark(tester, at);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await mark(tester, state(tester).pointing!);
}

/// Follows the pointer until the rule lands, [most] marks at most.
Future<void> markByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
