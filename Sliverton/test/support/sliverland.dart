import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliverton/sliver/levels.dart';
import 'package:sliverton/ui/app.dart';
import 'package:sliverton/ui/sliver_screen.dart';
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
  await tester.pumpWidget(const SlivertonApp());
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

SliverScreenState state(WidgetTester tester) =>
    tester.state<SliverScreenState>(find.byType(SliverScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps the mark [which], 0, 1 or 2, one twelfth on or back.
Future<void> stepMark(WidgetTester tester, int which, int by) async {
  await tester.tap(find.byKey(Key('mark$which${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Steps the three marks to [marks]; stops if the ask ends first, or if
/// a tap changes nothing, which would otherwise spin here for ever.
Future<void> setMarks(WidgetTester tester, List<int> marks) async {
  for (var i = 0; i < 3; i++) {
    while (!state(tester).play.isOver && state(tester).play.marks[i] != marks[i]) {
      final was = state(tester).play.marks[i];
      await stepMark(tester, i, marks[i] > was ? 1 : -1);
      if (state(tester).play.marks[i] == was) return;
    }
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await stepMark(tester, which, by);
}

/// Follows the pointer until the setting lands, [most] steps at most.
Future<void> marksByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
