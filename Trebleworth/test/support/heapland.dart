import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trebleworth/heap/levels.dart';
import 'package:trebleworth/heap/play.dart';
import 'package:trebleworth/ui/app.dart';
import 'package:trebleworth/ui/heap_screen.dart';
import 'package:trebleworth/ui/heapview.dart';
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
  await tester.pumpWidget(const TrebleworthApp());
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

HeapScreenState state(WidgetTester tester) =>
    tester.state<HeapScreenState>(find.byType(HeapScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps shelf number [t] through the painter's metrics.
Future<void> takeHeap(WidgetTester tester, int t) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  final i = state(tester).play.level.shelf.indexOf(t);
  await tester.tapAt(room.topLeft + metrics.shelfRect(i).center);
  await tester.pumpAndSettle();
}

/// Taps slot [i].
Future<void> dropSlot(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.slotRect(i).center);
  await tester.pumpAndSettle();
}

/// Takes every heap of [heaps] in turn.
Future<void> takeAll(WidgetTester tester, List<int> heaps) async {
  for (final t in heaps) {
    await takeHeap(tester, t);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, what) = state(tester).pointing!;
  switch (aim) {
    case Aim.shelf:
      await takeHeap(tester, what);
    case Aim.slot:
      await dropSlot(tester, what);
  }
}

/// Follows the pointer until the heaps land, [most] steps at most.
Future<void> heapByPointer(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
