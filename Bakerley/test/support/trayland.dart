import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bakerley/tray/levels.dart';
import 'package:bakerley/ui/app.dart';
import 'package:bakerley/ui/tray_screen.dart';
import 'package:bakerley/ui/trayview.dart';
import 'package:bakerley/tray/play.dart';
import 'package:bakerley/tray/rules.dart';
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
  await tester.pumpWidget(const BakerleyApp());
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

TrayScreenState state(WidgetTester tester) =>
    tester.state<TrayScreenState>(find.byType(TrayScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps tray cell (x, y) through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cellAt(x, y));
  await tester.pumpAndSettle();
}

/// Taps kind [k] in the bag.
Future<void> takeKind(WidgetTester tester, int k) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.bagAt(k));
  await tester.pumpAndSettle();
}

/// Takes kind [k], turns and flips it to orientation [o], and lays it
/// with its top left at (x, y).
Future<void> lay(WidgetTester tester, int k, int o, int x, int y) async {
  await takeKind(tester, k);
  var guard = 0;
  while (state(tester).play.facing != o && guard++ < 8) {
    final move = Rules.firstMove(k, state(tester).play.facing, o);
    await press(tester, move == 'flip' ? 'Flip' : 'Turn');
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
    case Aim.flip:
      await press(tester, 'Flip');
    case Aim.cell:
    case Aim.lift:
      await tapCell(tester, a, b);
  }
}

/// Follows the pointer until the tray is filled, [most] steps at most.
Future<void> fillByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
