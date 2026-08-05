import 'package:flutter_test/flutter_test.dart';
import 'package:skeinmoor/thread/boards.dart';

import '../support/thread.dart';

void main() {
  testWidgets('a board opens with every thread loose', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.filled, play.field.threads * 2);
    expect(play.joined, 0);
    expect(find.text(Boards.at(0).name), findsOneWidget);
    expect(
      find.textContaining('${play.field.threads} joined'),
      findsOneWidget,
    );
  });

  testWidgets('touching an end takes hold of its thread', (tester) async {
    await open(tester, which: 0);
    final field = state(tester).play.field;

    await touch(tester, field.ends[1].$1);
    expect(state(tester).thread, 1);
    expect(state(tester).play.headOf(1), field.ends[1].$1);
  });

  testWidgets('and the next cell draws it there', (tester) async {
    await open(tester, which: 0);
    final screen = state(tester);
    final first = screen.guide.answer[0][1];

    await touch(tester, screen.play.fromOf(0));
    await touch(tester, first);

    expect(state(tester).play.pathOf(0), hasLength(2));
    expect(state(tester).play.ownerOf(first), 0);
  });

  testWidgets('a finger dragged across the board lays a thread down',
      (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer[0];

    await dragThrough(tester, want.take(4).toList());

    expect(state(tester).play.pathOf(0), want.take(4));
    expect(state(tester).play.filled,
        state(tester).play.field.threads * 2 + 3);
  });

  testWidgets('and dragged back over its own line shortens it',
      (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer[0];

    await dragThrough(tester, want.take(4).toList());
    await dragThrough(tester, [want[3], want[2], want[1]]);

    expect(state(tester).play.pathOf(0), want.take(2));
    expect(state(tester).play.ownerOf(want[2]), -1);
  });

  testWidgets('a thread taking a cell from another cuts that one back',
      (tester) async {
    // The whole reason a thread can be drawn over another: the newer line
    // wins, and the older one gets out of the way.
    await open(tester, which: 0);
    final guide = state(tester).guide;

    // A cell on the a thread's way that the b thread can also reach.
    final mine = guide.answer[0];
    await dragThrough(tester, mine.take(4).toList());

    final taken = mine[2];
    final play = state(tester).play;
    var other = -1;
    for (var thread = 1; thread < play.field.threads && other < 0; thread++) {
      if (play.field.touching(play.fromOf(thread), taken)) other = thread;
    }
    if (other < 0) return; // no neighbour on this board; nothing to show

    // Dragged over, not tapped: tapping a line takes hold of it instead.
    await dragThrough(tester, [state(tester).play.fromOf(other), taken]);

    expect(state(tester).play.ownerOf(taken), other);
    expect(state(tester).play.pathOf(0), mine.take(2),
        reason: 'the cell they met on went with it');
  });

  testWidgets('a thread can be drawn from either end', (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer[0];

    await dragThrough(tester, want.reversed.take(3).toList());

    expect(state(tester).play.fromOf(0), want.last);
    expect(state(tester).play.pathOf(0), want.reversed.take(3));
  });

  testWidgets('and joins up when it reaches the far end', (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer[0];

    await dragThrough(tester, want);

    expect(state(tester).play.isJoined(0), isTrue);
    expect(state(tester).play.pathOf(0), want);
    expect(find.textContaining('1 of'), findsOneWidget);
  });

  testWidgets('Rub out takes the thread in hand off the board',
      (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer[0];

    await dragThrough(tester, want.take(4).toList());
    expect(state(tester).play.pathOf(0), hasLength(4));

    await press(tester, 'Rub out');
    expect(state(tester).play.pathOf(0), hasLength(1));
    expect(state(tester).play.ownerOf(want[1]), -1);
  });

  testWidgets('Again puts the whole board back', (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer[0];

    await dragThrough(tester, want.take(4).toList());
    await press(tester, 'Again');

    final play = state(tester).play;
    expect(play.filled, play.field.threads * 2);
    expect(play.joined, 0);
  });

  testWidgets('Show me points at a cell and says how many are left',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, screen.guide.answer[screen.thread][1]);
    expect(screen.hints, 1);
    expect(find.textContaining('goes through there next'), findsOneWidget);
    expect(find.textContaining('cells to go'), findsOneWidget);
  });

  testWidgets('and at what to rub out when a thread has wandered off',
      (tester) async {
    await open(tester, which: 0);
    final screen = state(tester);
    final field = screen.play.field;

    // A first step for some thread that is not the one the answer takes.
    var thread = -1;
    var wrong = -1;
    for (var t = 0; t < field.threads && thread < 0; t++) {
      for (var way = 0; way < 4; way++) {
        final at = field.beside(screen.play.fromOf(t), way);
        if (screen.play.canGoTo(t, at) && at != screen.guide.answer[t][1]) {
          thread = t;
          wrong = at;
          break;
        }
      }
    }
    expect(thread, isNonNegative);

    await touch(tester, state(tester).play.fromOf(thread));
    await touch(tester, wrong);
    await press(tester, 'Show me');

    expect(state(tester).pointing, wrong);
    expect(find.textContaining('does not go through there'), findsOneWidget);
  });

  testWidgets('joining every thread the short way is not finishing',
      (tester) async {
    // The mistake the game exists to catch. Every thread joined, the board
    // looking done, and cells still bare — so it says so.
    expect(await lazyFillSomething(tester, Boards.count), isNonNegative);

    final play = state(tester).play;
    expect(play.joined, play.field.threads);
    expect(play.empty, greaterThan(0));
    expect(play.isDone, isFalse);
    expect(find.textContaining('still empty'), findsOneWidget);
  });

  testWidgets('every board can be filled through the screen', (tester) async {
    // The proof that the game is playable: each board filled by asking what
    // comes next and touching it, through the same gestures a finger makes.
    for (var which = 0; which < Boards.count; which++) {
      await open(tester, which: which);
      await fillIt(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Boards.at(which).name);
      expect(play.empty, 0, reason: Boards.at(which).name);
      expect(play.joined, play.field.threads, reason: Boards.at(which).name);
      expect(find.bySemanticsLabel('board filled'), findsOneWidget,
          reason: Boards.at(which).name);
    }
  });
}
