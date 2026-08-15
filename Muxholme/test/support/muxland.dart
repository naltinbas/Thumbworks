import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muxholme/miu/levels.dart';
import 'package:muxholme/ui/app.dart';
import 'package:muxholme/ui/sheet_screen.dart';
import 'package:muxholme/ui/sheetview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a string, or on the sham when [which] is null.
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
  await tester.pumpWidget(const MuxholmeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few strings only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

SheetScreenState state(WidgetTester tester) =>
    tester.state<SheetScreenState>(find.byType(SheetScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps letter [p] of the string through the painter's metrics.
Future<void> tapLetter(WidgetTester tester, int p) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(p));
  await tester.pumpAndSettle();
}

/// Makes a move: the buttons for rules one and two, a letter for three
/// and four.
Future<void> make(WidgetTester tester, (int, int) move) async {
  switch (move.$1) {
    case 1:
      await press(tester, 'Rule I: add U');
    case 2:
      await press(tester, 'Rule II: double');
    default:
      await tapLetter(tester, move.$2);
  }
}

/// Makes moves one after another.
Future<void> makeAll(WidgetTester tester, List<(int, int)> moves) async {
  for (final m in moves) {
    await make(tester, m);
  }
}

/// Derives the string as the pointer says.
Future<void> deriveByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final move = state(tester).pointing!;
    await make(tester, move);
  }
}
