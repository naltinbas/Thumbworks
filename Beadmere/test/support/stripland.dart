import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beadmere/strip/levels.dart';
import 'package:beadmere/ui/app.dart';
import 'package:beadmere/ui/strip_screen.dart';
import 'package:beadmere/ui/stripview.dart';
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
  await tester.pumpWidget(const BeadmereApp());
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

StripScreenState state(WidgetTester tester) =>
    tester.state<StripScreenState>(find.byType(StripScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns bead [which] over.
Future<void> turn(WidgetTester tester, int which) async {
  final room = board(tester);
  await tester.tapAt(
      room.topLeft + Metrics(state(tester).play, room.size).at(which));
  await tester.pumpAndSettle();
}

/// Turns each of [beads] over in turn, stopping if the ask ends first.
Future<void> turnAll(WidgetTester tester, List<int> beads) async {
  for (final bead in beads) {
    if (state(tester).play.isOver) return;
    await turn(tester, bead);
  }
}

/// Does what the pointer says, once.
Future<void> turnByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await turn(tester, state(tester).pointing!);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> stringByPointer(WidgetTester tester, {int most = 14}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await turnByPointer(tester);
  }
}
