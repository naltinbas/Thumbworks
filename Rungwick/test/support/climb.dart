import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rungwick/best.dart';
import 'package:rungwick/ladder/graph.dart';
import 'package:rungwick/ui/app.dart';
import 'package:rungwick/ui/climb_screen.dart';

/// The bits every test that climbs a ladder needs.
///
/// The word graph is handed in rather than built on an isolate: it is the
/// same graph either way, and a test that waits for one it already has is a
/// test nobody runs.

/// A phone to lay a ladder out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last climb's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  required Ladder ladder,
  int? which,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(RungwickApp(
    key: ValueKey(_openings++),
    ladder: ladder,
    opensAt: which,
    best: best,
  ));
  await tester.pump();
}

ClimbScreenState state(WidgetTester tester) =>
    tester.state<ClimbScreenState>(find.byType(ClimbScreen));

/// Changes one letter of the word in hand: tap the letter, then the one to
/// put there. That is the only move the game has.
Future<void> change(WidgetTester tester, int at, String to) async {
  await tester.tap(find.bySemanticsLabel(RegExp('change the ${_ordinal(at)} letter')));
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('the letter $to'));
  await tester.pump();
}

/// Climbs to a word by finding which letter differs and changing it.
Future<void> climbTo(WidgetTester tester, String word) async {
  final here = state(tester).play.here;
  for (var at = 0; at < word.length; at++) {
    if (here[at] != word[at]) {
      await change(tester, at, word[at]);
      return;
    }
  }
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Climbs the whole ladder by asking and doing what it says.
Future<void> climbIt(WidgetTester tester, {int most = 20}) async {
  for (var rung = 0; rung < most; rung++) {
    if (state(tester).play.isDone) return;
    final next = state(tester).play.nextRung;
    if (next == null) return;
    await climbTo(tester, next);
  }
}

String _ordinal(int at) => switch (at) {
      0 => 'first',
      1 => 'second',
      2 => 'third',
      3 => 'fourth',
      4 => 'fifth',
      _ => '${at + 1}th',
    };
