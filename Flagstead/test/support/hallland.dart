import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flagstead/hall/levels.dart';
import 'package:flagstead/ui/app.dart';
import 'package:flagstead/ui/hall_screen.dart';
import 'package:flagstead/ui/hallview.dart';
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
  await tester.pumpWidget(const FlagsteadApp());
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

HallScreenState state(WidgetTester tester) =>
    tester.state<HallScreenState>(find.byType(HallScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> pressKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Stands the peg on the point [x], [y] by tapping it.
Future<void> standAt(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + Metrics(room.size).at(x, y));
  await tester.pumpAndSettle();
}

/// Sets the hall and the peg, stopping if the ask ends first or a tap
/// changes nothing.
Future<void> setStanding(
    WidgetTester tester, int wide, int tall, int x, int y) async {
  for (final each in [(0, wide), (1, tall)]) {
    while (!state(tester).play.isOver) {
      final at = each.$1 == 0 ? state(tester).play.wide : state(tester).play.tall;
      if (at == each.$2) break;
      final by = at < each.$2 ? 1 : -1;
      await pressKey(tester,
          '${each.$1 == 0 ? 'wide' : 'tall'}${by > 0 ? '+' : ''}$by');
      final now = each.$1 == 0 ? state(tester).play.wide : state(tester).play.tall;
      if (now == at) return;
    }
  }
  if (state(tester).play.isOver) return;
  if (state(tester).play.px != x || state(tester).play.py != y) {
    await standAt(tester, x, y);
  }
}

/// Does what the pointer says, once.
Future<void> stepByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  switch (aim.$1) {
    case 'wide':
      await pressKey(tester, 'wide${aim.$2 > 0 ? '+' : ''}${aim.$2}');
    case 'tall':
      await pressKey(tester, 'tall${aim.$2 > 0 ? '+' : ''}${aim.$2}');
    default:
      await standAt(tester, aim.$2, aim.$3);
  }
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> standByPointer(WidgetTester tester, {int most = 14}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await stepByPointer(tester);
  }
}
