import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squarebrook/stones/levels.dart';
import 'package:squarebrook/ui/app.dart';
import 'package:squarebrook/ui/stones_screen.dart';
import 'package:squarebrook/ui/stonesview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a number, or on the sham when [which] is null.
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
  await tester.pumpWidget(const SquarebrookApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few numbers only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

StonesScreenState state(WidgetTester tester) =>
    tester.state<StonesScreenState>(find.byType(StonesScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

Metrics metrics(WidgetTester tester) => Metrics(state(tester).play, board(tester).size);

/// Picks stone [s] from the rack.
Future<void> pickStone(WidgetTester tester, int s) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + metrics(tester).rackAt(s));
  await tester.pumpAndSettle();
}

/// Picks stones one after another.
Future<void> pickAll(WidgetTester tester, List<int> stones) async {
  for (final s in stones) {
    await pickStone(tester, s);
  }
}

/// Lifts the [i]th stone picked.
Future<void> liftStone(WidgetTester tester, int i) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + metrics(tester).pickedRect(i).center);
  await tester.pumpAndSettle();
}

/// Makes the number as the pointer says.
Future<void> makeByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (what, x) = state(tester).pointing!;
    if (what == 'pick') {
      await pickStone(tester, x);
    } else {
      await liftStone(tester, x);
    }
  }
}
