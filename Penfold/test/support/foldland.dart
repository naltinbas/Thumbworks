import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/fold/levels.dart';
import 'package:penfold/ui/app.dart';
import 'package:penfold/ui/fold_screen.dart';
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
  await tester.pumpWidget(const PenfoldApp());
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

FoldScreenState state(WidgetTester tester) =>
    tester.state<FoldScreenState>(find.byType(FoldScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Blows whistle [which], 0 for the left and 1 for the right.
Future<void> blow(WidgetTester tester, int which) async {
  await tester.tap(find.byKey(Key(which == 0 ? 'left' : 'right')));
  await tester.pumpAndSettle();
}

/// Blows the whistles of [call] in turn, stopping if the ask ends
/// first.
Future<void> blowCall(WidgetTester tester, List<int> call) async {
  for (final whistle in call) {
    if (state(tester).play.isOver) return;
    await blow(tester, whistle);
  }
}

/// Does what the pointer says, once.
Future<void> blowByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await blow(tester, state(tester).pointing!);
}

/// Follows the pointer until the flock comes in, [most] whistles at
/// most.
Future<void> gatherByPointer(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await blowByPointer(tester);
  }
}
