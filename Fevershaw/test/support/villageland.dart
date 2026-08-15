import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fevershaw/village/levels.dart';
import 'package:fevershaw/ui/app.dart';
import 'package:fevershaw/ui/village_screen.dart';
import 'package:fevershaw/ui/villageview.dart';
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
  await tester.pumpWidget(const FevershawApp());
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

VillageScreenState state(WidgetTester tester) =>
    tester.state<VillageScreenState>(find.byType(VillageScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps dial [dial]'s cell [i] through the painter's metrics: 0 the
/// fever, 1 the catch, 2 the alarm.
Future<void> tapDial(WidgetTester tester, int dial, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(dial, i));
  await tester.pumpAndSettle();
}

/// Sets the three dials by index.
Future<void> setVillage(WidgetTester tester, int fever, int catchAt, int alarmAt) async {
  if (state(tester).play.catchAt != catchAt) await tapDial(tester, 1, catchAt);
  if (!state(tester).play.isOver && state(tester).play.alarmAt != alarmAt) await tapDial(tester, 2, alarmAt);
  if (!state(tester).play.isOver && state(tester).play.prevalence != fever) await tapDial(tester, 0, fever);
}

/// Sets what the pointer says, once.
Future<void> setByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (dial, i) = state(tester).pointing!;
  await tapDial(tester, dial, i);
}

/// Follows the pointer until the ask is met, [most] taps at most.
Future<void> settleByPointer(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await setByPointer(tester);
  }
}
