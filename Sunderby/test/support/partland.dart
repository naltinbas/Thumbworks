import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunderby/part/levels.dart';
import 'package:sunderby/part/play.dart';
import 'package:sunderby/ui/app.dart';
import 'package:sunderby/ui/part_screen.dart';
import 'package:sunderby/ui/partview.dart';
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
  await tester.pumpWidget(const SunderbyApp());
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

PartScreenState state(WidgetTester tester) =>
    tester.state<PartScreenState>(find.byType(PartScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps shelf size [k] through the painter's metrics.
Future<void> addPart(WidgetTester tester, int k) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.shelfRect(k).center);
  await tester.pumpAndSettle();
}

/// Taps the [i]th row of dots.
Future<void> dropRow(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.rowRect(i).center);
  await tester.pumpAndSettle();
}

/// Adds every part of [parts] in turn.
Future<void> addAll(WidgetTester tester, List<int> parts) async {
  for (final k in parts) {
    await addPart(tester, k);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, what) = state(tester).pointing!;
  switch (aim) {
    case Aim.add:
      await addPart(tester, what);
    case Aim.drop:
      await dropRow(tester, what);
  }
}

/// Follows the pointer until the parts land, [most] steps at most.
Future<void> sunderByPointer(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
