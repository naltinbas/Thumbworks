import 'package:rickmere/rick/levels.dart';
import 'package:rickmere/ui/rick_screen.dart';
import 'package:rickmere/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:rickmere/ui/rickview.dart';
import 'package:flutter_test/flutter_test.dart';
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
  await tester.pumpWidget(const RickmereApp());
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

RickScreenState state(WidgetTester tester) =>
    tester.state<RickScreenState>(find.byType(RickScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a peg sits on the screen, which is where a thumb goes.
Offset pegAt(WidgetTester tester, (int, int) peg) {
  final where = board(tester);
  return where.topLeft + Metrics(state(tester).play, where.size).peg(peg);
}

/// Taps a peg, which lifts the post standing there or puts one down.
Future<void> tapPeg(WidgetTester tester, (int, int) peg) async {
  await tester.tapAt(pegAt(tester, peg));
  await tester.pumpAndSettle();
}

/// Moves the post at [from] to [to].
Future<void> movePost(
    WidgetTester tester, (int, int) from, (int, int) to) async {
  await tapPeg(tester, from);
  await tapPeg(tester, to);
}

/// Stands the three posts on [want], moving whichever are out of place.
Future<void> setField(WidgetTester tester, List<(int, int)> want,
    {int most = 8}) async {
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver) return;
    var post = -1;
    for (var i = 0; i < 3; i++) {
      if (!want.contains(was.posts[i])) {
        post = i;
        break;
      }
    }
    if (post < 0) return;
    final peg = want.firstWhere((p) => !was.posts.contains(p));
    await movePost(tester, was.posts[post], peg);
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  await movePost(tester, state(tester).play.posts[aim.$1], aim.$2);
}

/// Follows the pointer until the field lands, [most] moves at most.
Future<void> standByPointer(WidgetTester tester, {int most = 8}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
