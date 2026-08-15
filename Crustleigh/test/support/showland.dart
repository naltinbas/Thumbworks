import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crustleigh/show/levels.dart';
import 'package:crustleigh/ui/app.dart';
import 'package:crustleigh/ui/show_screen.dart';
import 'package:crustleigh/ui/showview.dart';
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
  await tester.pumpWidget(const CrustleighApp());
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

ShowScreenState state(WidgetTester tester) =>
    tester.state<ShowScreenState>(find.byType(ShowScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps [pie] on judge [j]'s card through the painter's metrics.
Future<void> tapPie(WidgetTester tester, int j, int pie) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(j, pie));
  await tester.pumpAndSettle();
}

/// Taps until judge [j]'s ballot reads [ranking], first to last.
Future<void> setBallot(WidgetTester tester, int j, List<int> ranking) async {
  for (var i = 0; i < ranking.length; i++) {
    var guard = 0;
    while (state(tester).play.profile[j][i] != ranking[i] && guard++ < 8) {
      await tapPie(tester, j, ranking[i]);
    }
  }
}

/// Does what the pointer says, once.
Future<void> moveByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (j, pie) = state(tester).pointing!;
  await tapPie(tester, j, pie);
}

/// Follows the pointer until the ask is met, [most] moves at most.
Future<void> judgeByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await moveByPointer(tester);
  }
}
