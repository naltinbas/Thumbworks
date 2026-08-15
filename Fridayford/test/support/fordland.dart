import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fridayford/almanac/levels.dart';
import 'package:fridayford/ui/app.dart';
import 'package:fridayford/ui/year_screen.dart';
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
  await tester.pumpWidget(const FridayfordApp());
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

YearScreenState state(WidgetTester tester) =>
    tester.state<YearScreenState>(find.byType(YearScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Moves the first of January on a day through the button.
Future<void> nextDay(WidgetTester tester) => press(tester, 'Next day');

/// Makes the year leap, or common, through the button.
Future<void> toggleLeap(WidgetTester tester) async {
  await tester.tap(find.textContaining('Make it'));
  await tester.pumpAndSettle();
}

/// Sets the year as the pointer says.
Future<void> setByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 16) {
    await press(tester, 'Show me');
    final what = state(tester).pointing!;
    if (what == 'day') {
      await nextDay(tester);
    } else {
      await toggleLeap(tester);
    }
  }
}
