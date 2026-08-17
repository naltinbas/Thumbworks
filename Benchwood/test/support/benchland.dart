import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:benchwood/bench/levels.dart';
import 'package:benchwood/ui/app.dart';
import 'package:benchwood/ui/bench_screen.dart';
import 'package:benchwood/ui/benchview.dart';
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
  await tester.pumpWidget(const BenchwoodApp());
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

BenchScreenState state(WidgetTester tester) =>
    tester.state<BenchScreenState>(find.byType(BenchScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the tool in bench slot [i], which carries it back to the store.
Future<void> carry(WidgetTester tester, int i) async {
  final room = board(tester);
  await tester.tapAt(
      room.topLeft + Metrics(state(tester).play, room.size).slotAt(i).center);
  await tester.pumpAndSettle();
}

/// Carries back the slots of [slots] in turn, stopping if the run ends
/// first.
Future<void> carryAll(WidgetTester tester, List<int> slots) async {
  for (final slot in slots) {
    if (state(tester).play.isOver) return;
    await carry(tester, slot);
  }
}

/// Does what the pointer says, once.
Future<void> carryByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await carry(tester, state(tester).pointing!);
}

/// Follows the pointer to the end of the card, [most] carries at most.
Future<void> workByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.finished; k++) {
    await carryByPointer(tester);
  }
}
