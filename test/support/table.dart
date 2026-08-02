import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazardwell/best.dart';
import 'package:hazardwell/game/odds.dart';
import 'package:hazardwell/game/play.dart';
import 'package:hazardwell/ui/app.dart';
import 'package:hazardwell/ui/table_screen.dart';

/// Dice that have been told what to throw.
///
/// The game asks for its dice through [Random], so a test can hand it a set
/// that comes up the way the test needs without the game knowing or caring.
class Loaded implements Random {
  Loaded(this.faces);

  /// What comes up, in order, from one to six. It goes round again at the
  /// end, so a test only writes down the throws it cares about.
  final List<int> faces;

  int thrown = 0;

  @override
  int nextInt(int max) => faces[thrown++ % faces.length] - 1;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

/// A phone to lay a table out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last game's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  required Odds odds,
  bool atTable = true,
  Random? dice,
  Play? from,
  Best? best,
  bool showOdds = false,
  Size screen = phone,
  Duration theirPause = const Duration(milliseconds: 850),
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(HazardwellApp(
    key: ValueKey(_openings++),
    odds: odds,
    best: best,
    opensAtTable: atTable,
    dice: dice,
    opensWith: from,
    showOdds: showOdds,
    theirPause: theirPause,
  ));
  await tester.pump();
}

TableScreenState state(WidgetTester tester) =>
    tester.state<TableScreenState>(find.byType(TableScreen));

/// Taps a button by the words on it, scrolling to it if it is off the screen.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Lets the house take its turn, however many moves that is.
Future<void> letThemPlay(
  WidgetTester tester, {
  Duration pause = const Duration(milliseconds: 850),
}) async {
  for (var i = 0; i < 60; i++) {
    if (!state(tester).theirs || state(tester).play.isOver) return;
    await tester.pump(pause + const Duration(milliseconds: 10));
  }
}
