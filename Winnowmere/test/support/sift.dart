import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winnowmere/best.dart';
import 'package:winnowmere/sift/fewest.dart';
import 'package:winnowmere/ui/app.dart';
import 'package:winnowmere/ui/frame.dart';
import 'package:winnowmere/ui/sift_screen.dart';

/// The bits every test that builds a network needs.

/// A phone to lay the lines out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last works'.
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

  // In a boundary, so a screenshot can be taken of whatever a test leaves on
  // it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: WinnowmereApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

SiftScreenState state(WidgetTester tester) =>
    tester.state<SiftScreenState>(find.byType(SiftScreen));

/// Where a line is on the screen, at a given comparator's position, worked
/// out the way the game works it out.
Offset whereIs(WidgetTester tester, int line, {int at = -1}) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(SiftScreenState.frameKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  // Where the next comparator will go, which is past every one already in.
  // Tapping a line where one already sits would take that one out instead.
  final x = at < 0 ? metrics.xOf(state(tester).play.count) : metrics.xOf(at);
  return box.localToGlobal(Offset(x, metrics.yOf(line)));
}

/// Taps a line.
Future<void> touch(WidgetTester tester, int line) async {
  await tester.tapAt(whereIs(tester, line));
  await tester.pump();
}

/// Puts a comparator between two lines the way a finger does.
Future<void> put(WidgetTester tester, int one, int other) async {
  await touch(tester, one);
  await touch(tester, other);
}

/// Taps a comparator, which takes it out.
Future<void> takeOut(WidgetTester tester, int which) async {
  final cross = state(tester).play.sieve.crosses[which];
  final box = tester.renderObject<RenderBox>(
    find.byKey(SiftScreenState.frameKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(Offset(
    metrics.xOf(which),
    (metrics.yOf(cross.upper) + metrics.yOf(cross.lower)) / 2,
  )));
  await tester.pump();
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Finishes the network the fewest way there is, two taps a comparator.
Future<void> sortItAll(WidgetTester tester) async {
  final rest = Fewest.fromHere(state(tester).play.sieve)!.$2;
  for (var i = state(tester).play.count; i < rest.crosses.length; i++) {
    await put(tester, rest.crosses[i].upper, rest.crosses[i].lower);
  }
}
