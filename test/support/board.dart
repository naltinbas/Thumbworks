import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chalkway/done.dart';
import 'package:chalkway/sim/shapes.dart';
import 'package:chalkway/sim/stroke.dart';
import 'package:chalkway/sim/world.dart';
import 'package:chalkway/ui/app.dart';
import 'package:chalkway/ui/board_screen.dart';
import 'package:chalkway/ui/slate_painter.dart';

/// The bits every test that draws on a board needs.
///
/// Nothing here is a stand-in for the game. The screens are the real ones and
/// the strokes are made by dragging a finger across them; what these hide is
/// the arithmetic of turning a point on the slate into a point on a phone,
/// which every test would otherwise repeat.

/// A phone to lay a board out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  int? level,
  Drawing? opening,
  Done? done,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChalkwayApp(opensAt: level, opening: opening, done: done),
  );
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

Finder slate() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is SlatePainter,
    );

SlatePainter painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(slate().first).painter! as SlatePainter;

Metrics metricsOf(WidgetTester tester) => painterOf(tester).metrics;

/// Where a point of the world is on the screen.
Offset onScreen(WidgetTester tester, Spot spot) =>
    tester.getTopLeft(slate().first) + metricsOf(tester).toScreen(spot);

/// Drags a finger from one point of the world to another, in steps, the way a
/// finger actually arrives — a stroke made of one move is a stroke of two
/// points, and the thinning would never come into it.
Future<void> drawFrom(
  WidgetTester tester,
  Spot from,
  Spot to, {
  int steps = 12,
}) async {
  final gesture = await tester.startGesture(onScreen(tester, from));
  await tester.pump();
  for (var i = 1; i <= steps; i++) {
    await gesture.moveTo(
      onScreen(tester, from + (to - from) * (i / steps)),
    );
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}

/// Draws the level's own answer on the board, stroke by stroke.
Future<void> drawTheAnswer(WidgetTester tester) async {
  for (final stroke in state(tester).level.solution) {
    for (var i = 1; i < stroke.length; i++) {
      await drawFrom(tester, stroke[i - 1], stroke[i]);
    }
  }
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
}

/// Runs the ball until it stops, a frame at a time.
///
/// Plain pumps, never pumpAndSettle: a board with a ball on it is never
/// settled, and pumpAndSettle would run the whole thing to its end in one go
/// and then keep going.
Future<void> runOut(WidgetTester tester) async {
  const frame = Duration(milliseconds: 50);
  for (var i = 0; i < 4000; i++) {
    final world = state(tester).world;
    if (world != null && world.isOver) return;
    await tester.pump(frame);
  }
  fail('the run never ended');
}

/// Lets go and watches, which is the second half of every level.
Future<Ending> letGo(WidgetTester tester) async {
  await press(tester, 'Let go');
  await runOut(tester);
  return state(tester).world!.ending;
}
