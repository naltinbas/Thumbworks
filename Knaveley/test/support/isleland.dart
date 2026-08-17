import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knaveley/isle/levels.dart';
import 'package:knaveley/ui/app.dart';
import 'package:knaveley/ui/isle_screen.dart';
import 'package:knaveley/ui/isleview.dart';
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
  await tester.pumpWidget(const KnaveleyApp());
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

IsleScreenState state(WidgetTester tester) =>
    tester.state<IsleScreenState>(find.byType(IsleScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps villager [who], turning them from knight to knave or back.
Future<void> tapVillager(WidgetTester tester, int who) async {
  final room = board(tester);
  await tester.tapAt(
      room.topLeft + Metrics(state(tester).play, room.size).at(who));
  await tester.pumpAndSettle();
}

/// Names the villagers as [kinds] asks, stopping if the ask ends first.
Future<void> nameAll(WidgetTester tester, List<bool> kinds) async {
  for (var who = 0; who < kinds.length; who++) {
    if (state(tester).play.isOver) return;
    if (state(tester).play.kinds[who] == kinds[who]) continue;
    final was = state(tester).play.kinds[who];
    await tapVillager(tester, who);
    if (state(tester).play.kinds[who] == was) return;
  }
}

/// Does what the pointer says, once.
Future<void> nameByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapVillager(tester, state(tester).pointing!);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> nameAllByPointer(WidgetTester tester, {int most = 8}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await nameByPointer(tester);
  }
}
