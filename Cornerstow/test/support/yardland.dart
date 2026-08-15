import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cornerstow/yard/levels.dart';
import 'package:cornerstow/ui/app.dart';
import 'package:cornerstow/ui/yard_screen.dart';
import 'package:cornerstow/ui/yardview.dart';
import 'package:cornerstow/yard/play.dart';
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
  await tester.pumpWidget(const CornerstowApp());
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

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps yard cell (x, y) through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cellAt(x, y));
  await tester.pumpAndSettle();
}

/// Taps tray kind [kind].
Future<void> takeKind(WidgetTester tester, int kind) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.trayAt(kind));
  await tester.pumpAndSettle();
}

/// Takes kind [kind], turns it upright if asked, and lays it at (x, y).
Future<void> lay(WidgetTester tester, int kind, int x, int y, {bool upright = false}) async {
  await takeKind(tester, kind);
  if (state(tester).play.upright != upright) {
    await press(tester, 'Turn');
  }
  await tapCell(tester, x, y);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, a, b) = state(tester).pointing!;
  switch (aim) {
    case Aim.tray:
      await takeKind(tester, a);
    case Aim.turn:
      await press(tester, 'Turn');
    case Aim.cell:
    case Aim.lift:
      await tapCell(tester, a, b);
  }
}

/// Follows the pointer until the yard is paved, [most] steps at most.
Future<void> paveByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
