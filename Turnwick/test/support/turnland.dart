import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwick/pack/levels.dart';
import 'package:turnwick/ui/app.dart';
import 'package:turnwick/ui/pack_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a pattern, or on the sham when [which] is null.
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
  await tester.pumpWidget(const TurnwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few patterns only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

PackScreenState state(WidgetTester tester) =>
    tester.state<PackScreenState>(find.byType(PackScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Cuts the pack through the button.
Future<void> cut(WidgetTester tester) => press(tester, 'Cut');

/// Turns the top two through the button.
Future<void> turnTwo(WidgetTester tester) => press(tester, 'Turn two');

/// Makes moves one after another: true for a turn, false for a cut.
Future<void> makeAll(WidgetTester tester, List<bool> moves) async {
  for (final m in moves) {
    if (m) {
      await turnTwo(tester);
    } else {
      await cut(tester);
    }
  }
}

/// Cuts and turns as the pointer says.
Future<void> playByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final move = state(tester).pointing!;
    if (move) {
      await turnTwo(tester);
    } else {
      await cut(tester);
    }
  }
}
