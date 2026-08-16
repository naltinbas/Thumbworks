import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kithwell/kith/levels.dart';
import 'package:kithwell/ui/app.dart';
import 'package:kithwell/ui/kith_screen.dart';
import 'package:kithwell/ui/kithview.dart';
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
  await tester.pumpWidget(const KithwellApp());
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

KithScreenState state(WidgetTester tester) =>
    tester.state<KithScreenState>(find.byType(KithScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps person [v] through the painter's metrics.
Future<void> tapPerson(WidgetTester tester, int v) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(v));
  await tester.pumpAndSettle();
}

/// Makes or parts the friendships given as pairs of people, each by
/// its two taps.
Future<void> befriend(WidgetTester tester, List<(int, int)> pairs) async {
  for (final (a, b) in pairs) {
    if (state(tester).play.isOver) return;
    await tapPerson(tester, a);
    await tapPerson(tester, b);
  }
}

/// Does what the pointer says, once: one tap.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (a, b, _) = state(tester).pointing!;
  final held = state(tester).play.held;
  await tapPerson(tester, a == b ? a : (held == a ? b : a));
}

/// Follows the pointer until the plan lands, [most] taps at most.
Future<void> planByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
