import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeinmoor/best.dart';
import 'package:skeinmoor/thread/play.dart';
import 'package:skeinmoor/ui/app.dart';
import 'package:skeinmoor/ui/board_screen.dart';
import 'package:skeinmoor/ui/weave.dart';

/// The bits every test that fills a board needs.

/// A phone to lay the board out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last board's.
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
    child: SkeinmoorApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

/// Where a cell is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int at) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BoardScreenState.boardKey),
  );
  final metrics = Metrics(state(tester).play.field, box.size);
  return box.localToGlobal(metrics.middleOf(at));
}

/// Touches a cell.
Future<void> touch(WidgetTester tester, int at) async {
  await tester.tapAt(whereIs(tester, at));
  await tester.pump();
}

/// Drags a finger through a run of cells without lifting it, which is how the
/// game is really played.
Future<void> dragThrough(WidgetTester tester, List<int> cells) async {
  final finger = await tester.startGesture(whereIs(tester, cells.first));
  await tester.pump();
  for (final at in cells.skip(1)) {
    await finger.moveTo(whereIs(tester, at));
    await tester.pump();
  }
  await finger.up();
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

/// Fills the board by asking for a hint and doing what it says, over and
/// over. Every cell goes on through the screen.
Future<void> fillIt(WidgetTester tester, {int most = 120}) async {
  for (var turn = 0; turn < most; turn++) {
    final screen = state(tester);
    if (screen.play.isDone) return;
    final step = screen.guide.next(screen.play);
    if (step == null) return;
    // Take hold of the thread the hint is about, the way a finger would,
    // before drawing it on.
    if (screen.thread != step.thread) {
      await touch(tester, screen.play.headOf(step.thread));
    }
    await touch(tester, step.at);
  }
}

/// A shortest run of empty cells joining a thread's two ends, or null.
List<int>? shortestRun(Play play, int thread) {
  final field = play.field;
  final from = play.fromOf(thread);
  final to = play.toOf(thread);

  final came = List.filled(field.cells, -2);
  came[from] = -1;
  final todo = <int>[from];
  while (todo.isNotEmpty) {
    final here = todo.removeAt(0);
    if (here == to) break;
    for (var way = 0; way < 4; way++) {
      final next = field.beside(here, way);
      if (next < 0 || came[next] != -2) continue;
      if (next != to && play.ownerOf(next) >= 0) continue;
      came[next] = here;
      todo.add(next);
    }
  }
  if (came[to] == -2) return null;

  final run = <int>[];
  for (var at = to; at != from; at = came[at]) {
    run.insert(0, at);
  }
  return [from, ...run];
}

/// Fills a board the way somebody does who has not noticed the second rule:
/// every thread joined, one of them by a shorter way than the answer takes,
/// which leaves cells bare. Says whether it managed it.
Future<bool> lazyFill(WidgetTester tester, int which) async {
  await open(tester, which: which);
  final answer = state(tester).guide.answer;

  for (var lazy = 0; lazy < answer.length; lazy++) {
    await open(tester, which: which);
    for (var thread = 0; thread < answer.length; thread++) {
      if (thread != lazy) await dragThrough(tester, answer[thread]);
    }
    final run = shortestRun(state(tester).play, lazy);
    if (run == null || run.length >= answer[lazy].length) continue;
    await dragThrough(tester, run);
    return true;
  }
  return false;
}

/// The first board where somebody can join everything and still leave the
/// board bare, filled that way. -1 if there is no such board, which would
/// mean every thread on every board goes the shortest way it could — and
/// then there would be nothing to work out.
Future<int> lazyFillSomething(WidgetTester tester, int boards) async {
  for (var which = 0; which < boards; which++) {
    if (await lazyFill(tester, which)) return which;
  }
  return -1;
}

