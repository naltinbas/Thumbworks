import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedgemere/hedge/levels.dart';
import 'package:hedgemere/hedge/rules.dart';
import 'package:hedgemere/ui/app.dart';
import 'package:hedgemere/ui/hedge_screen.dart';
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
  await tester.pumpWidget(const HedgemereApp());
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

HedgeScreenState state(WidgetTester tester) =>
    tester.state<HedgeScreenState>(find.byType(HedgeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Hangs one post a step further along, or a step back.
Future<void> step(WidgetTester tester, int post, int by) async {
  await tester.tap(find.byKey(Key('post$post${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Walks the whole hanging to [want], a post a tap.
Future<void> setHanging(WidgetTester tester, List<int> want,
    {int most = 60}) async {
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver) return;
    var moved = false;
    for (var dial = 0; dial < Rules.hangs; dial++) {
      final at = was.hanging[dial];
      if (at == want[dial]) continue;
      await step(tester, dial + 3, at < want[dial] ? 1 : -1);
      moved = true;
      break;
    }
    if (!moved) return;
    // A tap that changes nothing means the hanging cannot get there.
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (dial, by) = state(tester).pointing!;
  await step(tester, dial + 3, by);
}

/// Follows the pointer until the hedge lands, [most] taps at most.
Future<void> peelByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
