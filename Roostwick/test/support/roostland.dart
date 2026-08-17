import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roostwick/roost/levels.dart';
import 'package:roostwick/ui/app.dart';
import 'package:roostwick/ui/roost_screen.dart';
import 'package:roostwick/ui/roostview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the wood when [which] is null.
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
  await tester.pumpWidget(const RoostwickApp());
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

RoostScreenState state(WidgetTester tester) =>
    tester.state<RoostScreenState>(find.byType(RoostScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a bird sits on the screen, which is where a thumb goes.
Offset birdAt(WidgetTester tester, int bird) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).perches[bird];
}

/// Where a hollow sits, for a tap that should land on nothing.
Offset hollowAt(WidgetTester tester, int hollow) {
  final where = board(tester);
  return where.topLeft + Metrics(state(tester).play, where.size).hollow(hollow);
}

/// Taps a bird, which sends it along its tether.
Future<void> tapBird(WidgetTester tester, int bird) async {
  await tester.tapAt(birdAt(tester, bird));
  await tester.pumpAndSettle();
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapBird(tester, state(tester).pointing!);
}

/// Follows the pointer until the wood settles, [most] taps at most.
Future<void> settleByPointer(WidgetTester tester, {int most = 8}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
