import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glintmere/glint/levels.dart';
import 'package:glintmere/ui/app.dart';
import 'package:glintmere/ui/glint_screen.dart';
import 'package:glintmere/ui/glintview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the mirror when [which] is null.
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
  await tester.pumpWidget(const GlintmereApp());
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

GlintScreenState state(WidgetTester tester) =>
    tester.state<GlintScreenState>(find.byType(GlintScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a peg of the mirror is drawn, which is where a thumb goes.
Offset pegAt(WidgetTester tester, int peg) {
  final where = board(tester);
  final play = state(tester).play;
  return where.topLeft +
      Metrics(play, where.size, showFold: play.gaveUp).at(peg, 0);
}

/// Taps beside the bounce, which slides it one peg that way.
Future<void> slideTowards(WidgetTester tester, int peg) async {
  await tester.tapAt(pegAt(tester, peg));
  await tester.pumpAndSettle();
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await slideTowards(tester, state(tester).play.next!);
}

/// Follows the pointer until the ask lands, [most] slides at most.
Future<void> catchByPointer(WidgetTester tester, {int most = 16}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
