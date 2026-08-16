import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beamsley/shadow/levels.dart';
import 'package:beamsley/shadow/rules.dart';
import 'package:beamsley/ui/app.dart';
import 'package:beamsley/ui/shadow_screen.dart';
import 'package:beamsley/ui/shadowview.dart';
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
  await tester.pumpWidget(const BeamsleyApp());
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

ShadowScreenState state(WidgetTester tester) =>
    tester.state<ShadowScreenState>(find.byType(ShadowScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps peg [p] through the painter's metrics.
Future<void> tapPeg(WidgetTester tester, Peg p) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.pegAt(p));
  await tester.pumpAndSettle();
}

/// Sets the pegs in turn.
Future<void> setPegs(WidgetTester tester, List<Peg> pegs) async {
  for (final p in pegs) {
    if (state(tester).play.isOver) return;
    await tapPeg(tester, p);
  }
}

/// Steps the cast of peg [which] one along, up or down.
Future<void> stepCast(WidgetTester tester, int which, int by) async {
  await tester.tap(find.byKey(Key('cast$which${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Steps the three casts to [casts]; stops if the ask ends first.
Future<void> setCasts(WidgetTester tester, List<int> casts) async {
  for (var i = 0; i < 3; i++) {
    while (!state(tester).play.isOver && state(tester).play.casts[i] != casts[i]) {
      final at = Rules.casts.indexOf(state(tester).play.casts[i]);
      final want = Rules.casts.indexOf(casts[i]);
      await stepCast(tester, i, want > at ? 1 : -1);
    }
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  final play = state(tester).play;
  if (aim.$1 == 'peg') {
    await tapPeg(tester, play.wanted!);
  } else if (aim.$1 == 'lift') {
    await tapPeg(tester, play.pegs.last);
  } else {
    await stepCast(tester, aim.$2, play.castWay(aim.$2));
  }
}

/// Follows the pointer until the setting lands, [most] steps at most.
Future<void> castByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
