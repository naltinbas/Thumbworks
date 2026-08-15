import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framley/wall/levels.dart';
import 'package:framley/ui/app.dart';
import 'package:framley/ui/wall_screen.dart';
import 'package:framley/ui/wallview.dart';
import 'package:framley/wall/play.dart';
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
  await tester.pumpWidget(const FramleyApp());
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

WallScreenState state(WidgetTester tester) =>
    tester.state<WallScreenState>(find.byType(WallScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps wall cell (x, y) through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cellAt(x, y));
  await tester.pumpAndSettle();
}

/// Taps tray frame [s].
Future<void> takeFrame(WidgetTester tester, int s) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.trayAt(s));
  await tester.pumpAndSettle();
}

/// Takes frame [s] and hangs it with its corner at (x, y).
Future<void> hang(WidgetTester tester, int s, int x, int y) async {
  await takeFrame(tester, s);
  await tapCell(tester, x, y);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, a, b) = state(tester).pointing!;
  switch (aim) {
    case Aim.tray:
      await takeFrame(tester, a);
    case Aim.cell:
    case Aim.lift:
      await tapCell(tester, a, b);
  }
}

/// Follows the pointer until the wall is hung, [most] steps at most.
Future<void> hangByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
