import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feltmere/hat/levels.dart';
import 'package:feltmere/hat/rules.dart';
import 'package:feltmere/ui/app.dart';
import 'package:feltmere/ui/hat_screen.dart';
import 'package:feltmere/ui/hatview.dart';
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
  await tester.pumpWidget(const FeltmereApp());
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

HatScreenState state(WidgetTester tester) =>
    tester.state<HatScreenState>(find.byType(HatScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the cell for villager [who] on sight [sight].
Future<void> tapCell(WidgetTester tester, int who, int sight) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + Metrics(room.size).cellAt(who, sight).center);
  await tester.pumpAndSettle();
}

/// Sets the whole agreement, cell by cell, stopping if the ask ends
/// first or a tap changes nothing.
Future<void> setAgreement(
    WidgetTester tester, List<List<int>> agreement) async {
  for (var who = 0; who < Rules.villagers; who++) {
    for (var sight = 0; sight < Rules.sights.length; sight++) {
      var guard = 0;
      while (!state(tester).play.isOver &&
          state(tester).play.agreement[who][sight] != agreement[who][sight] &&
          guard < 3) {
        final was = state(tester).play.agreement[who][sight];
        await tapCell(tester, who, sight);
        if (state(tester).play.agreement[who][sight] == was) return;
        guard++;
      }
    }
  }
}

/// Does what the pointer says, once.
Future<void> turnByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  await tapCell(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> agreeByPointer(WidgetTester tester, {int most = 16}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await turnByPointer(tester);
  }
}
