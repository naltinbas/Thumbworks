import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haulyard/best.dart';
import 'package:haulyard/ui/app.dart';
import 'package:haulyard/ui/yard_painter.dart';
import 'package:haulyard/ui/yard_screen.dart';
import 'package:haulyard/yard/haul.dart';
import 'package:haulyard/yard/yard.dart';

/// The bits every test that works a yard needs.
///
/// Nothing here stands in for the game. The screens are the real ones, and a
/// crate is shoved by tapping the square it is in.

/// A phone to lay a yard out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens.
///
/// It goes on the app as a key. Without one, pumping the app a second time in
/// the same test hands the new widget to the old state — which is holding the
/// yard the last one opened, and every expectation after that is about a game
/// nobody is looking at.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    HaulyardApp(key: ValueKey(_openings++), opensAt: which, best: best),
  );
  await tester.pump();
}

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Finder plot() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is YardPainter,
    );

YardPainter painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(plot().first).painter! as YardPainter;

Metrics metricsOf(WidgetTester tester) => painterOf(tester).metrics;

/// The middle of a square, on the screen.
Offset onScreen(WidgetTester tester, int at) =>
    tester.getTopLeft(plot().first) + metricsOf(tester).squareAt(at).center;

Future<void> tapSquare(WidgetTester tester, int at) async {
  await tester.tapAt(onScreen(tester, at));
  await tester.pump();
}

/// Swipes across the yard, which is the other way to take a step.
Future<void> swipe(WidgetTester tester, Way way) async {
  final middle = tester.getCenter(plot().first);
  await tester.fling(
    plot().first,
    Offset(way.column * 60, way.row * 60),
    600,
    initialOffset: middle - tester.getCenter(plot().first),
  );
  await tester.pump();
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
}

/// Works the yard through by asking the game and doing what it says.
///
/// The only way to finish a yard in a test without writing the answer down: it
/// taps Show me, reads the crate and the way off the screen's own state, and
/// shoves it.
Future<void> workItThrough(WidgetTester tester, {int most = 200}) async {
  for (var turn = 0; turn < most; turn++) {
    if (state(tester).yard.isDone) return;
    await press(tester, 'Show me');
    final painter = painterOf(tester);
    final crate = painter.pointAt;
    final way = painter.pointWay;
    if (crate == null || way == null) return;

    final stand = state(tester).yard.ground.beyond(crate, way.back);
    await tapSquare(tester, stand);
    await tapSquare(tester, crate);
  }
}

/// Walks the hauler round to the far side of the first yard's crate and
/// shoves it the wrong way until it is against the bottom wall, where it can
/// slide sideways for ever and never come off.
Future<void> spoilTheFirstYard(WidgetTester tester) async {
  final crate = state(tester).yard.crates.single;
  final above = state(tester).yard.ground.beyond(crate, Way.up);
  await tapSquare(tester, above);
  for (var i = 0; i < 3 && state(tester).saying == null; i++) {
    await swipe(tester, Way.down);
  }
}

/// The shortest way through from here, worked out afresh.
Haul haulFrom(WidgetTester tester) =>
    Hauler(state(tester).yard.ground).from(state(tester).yard);
