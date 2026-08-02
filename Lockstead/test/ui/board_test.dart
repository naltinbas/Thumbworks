import 'package:flutter_test/flutter_test.dart';
import 'package:lockstead/lock/boards.dart';
import 'package:lockstead/lock/lock.dart';
import 'package:lockstead/lock/marks.dart';
import 'package:lockstead/ui/board_screen.dart';
import 'package:lockstead/ui/title_screen.dart';

import '../support/bench.dart';

void main() {
  late Marks gate;

  setUpAll(() => gate = Marks.of(Boards.at(0).lock));

  group('getting in', () {
    testWidgets('the rack lists every lock and what it promises',
        (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      for (final board in Boards.all) {
        expect(find.text(board.name), findsOne);
        expect(
          find.text('${board.about} · ${board.codes} codes · '
              'always ${board.inside}'),
          findsOne,
        );
      }
    });

    testWidgets('and a lock opens when its row is tapped', (tester) async {
      await open(tester);
      await tester.tap(find.text('The garden gate'));
      await tester.pump();
      expect(find.byType(BoardScreen), findsOne);
    });

    testWidgets('a lock starts with every code possible and none tried',
        (tester) async {
      await open(tester, which: 0, marks: gate);
      final play = state(tester).play!;

      expect(play.could.length, 1296);
      expect(play.tries, isEmpty);
      expect(play.left, 5);
      expect(find.text('5 left'), findsOne);
      expect(find.text('1296 codes still fit'), findsOne);
    });
  });

  group('filling a row', () {
    testWidgets('a colour goes in the next empty peg', (tester) async {
      await open(tester, which: 0, marks: gate);
      await putPeg(tester, 2);
      await putPeg(tester, 5);

      expect(state(tester).picking, [2, 5]);
    });

    testWidgets('take back removes the last one, and stops at empty',
        (tester) async {
      await open(tester, which: 0, marks: gate);
      await putPeg(tester, 1);
      await press(tester, 'Take back');
      expect(state(tester).picking, isEmpty);

      await press(tester, 'Take back');
      expect(state(tester).picking, isEmpty, reason: 'nothing to take back');
    });

    testWidgets('and nothing can be tried until the row is full',
        (tester) async {
      await open(tester, which: 0, marks: gate);
      await putPeg(tester, 0);
      await putPeg(tester, 1);
      await press(tester, 'Try it');
      expect(state(tester).play!.tries, isEmpty);

      await putPeg(tester, 2);
      await putPeg(tester, 3);
      await press(tester, 'Try it');
      expect(state(tester).play!.tries, hasLength(1));
    });

    testWidgets('a fifth peg does not fit a four peg lock', (tester) async {
      await open(tester, which: 0, marks: gate);
      for (var i = 0; i < 6; i++) {
        await putPeg(tester, 0);
      }
      expect(state(tester).picking, hasLength(4));
    });
  });

  group('a guess', () {
    const lock = Lock(pegs: 4, colours: 6);

    testWidgets('comes back marked, and narrows what still fits',
        (tester) async {
      await open(
        tester,
        which: 0,
        marks: gate,
        secret: lock.codeOf([0, 1, 2, 3]),
      );
      await tryCode(tester, [0, 0, 1, 1]);

      final tried = state(tester).play!.tries.single;
      expect(tried.mark, const Mark(1, 1));
      expect(tried.left, lessThan(1296));
      expect(find.text('${tried.left} codes still fit'), findsOne);
    });

    testWidgets('opens the lock when every peg is right', (tester) async {
      await open(tester, which: 0, marks: gate, secret: 77);
      await tryCode(tester, lock.pegsOf(77));

      expect(state(tester).play!.isOpen, isTrue);
      expect(find.text('Open'), findsOne);
      expect(find.text('Another lock'), findsOne);
    });

    testWidgets('and runs the guesses out, which shows the code',
        (tester) async {
      // Five guesses that are all wrong on purpose: the code is one thing and
      // every guess is another.
      await open(
        tester,
        which: 0,
        marks: gate,
        secret: lock.codeOf([0, 0, 0, 0]),
      );
      for (var i = 0; i < 5; i++) {
        await tryCode(tester, [1, 2, 3, 4]);
      }

      expect(state(tester).play!.isLost, isTrue);
      expect(find.text('Still shut'), findsOne);
      expect(find.text('It was'), findsOne,
          reason: 'a lock that beat you should show what it was');
    });
  });

  group('being shown', () {
    testWidgets('fills the row and says what the guess is worth',
        (tester) async {
      await open(tester, which: 0, marks: gate);
      await press(tester, 'Show me');

      expect(state(tester).picking, hasLength(4));
      expect(state(tester).saying, contains('leaves the fewest standing'));
      expect(state(tester).saying, contains('out of 1296'));
    });

    testWidgets('and what it says is true: nothing else leaves less',
        (tester) async {
      // The claim behind the button. Whatever it offers, no other code in the
      // lock has a smaller worst case — checked against all 1296 of them.
      await open(tester, which: 0, marks: gate);
      await press(tester, 'Show me');
      final offered = Boards.at(0).lock.codeOf(state(tester).picking);

      final could = state(tester).play!.could;
      final mine = _worstFor(gate, could, offered);
      for (var guess = 0; guess < 1296; guess++) {
        expect(_worstFor(gate, could, guess), greaterThanOrEqualTo(mine),
            reason: 'code $guess leaves less behind than the one offered');
      }
    });

    testWidgets('picks every lock inside its promise, one guess at a time',
        (tester) async {
      // The claim the game is sold on, made through the screen and without
      // ever being told the code. Every lock, played by asking.
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        await open(tester, which: which, marks: Marks.of(board.lock));

        await pickIt(tester);
        expect(state(tester).play!.isOpen, isTrue,
            reason: '${board.name} was not opened in ${board.inside}');
        expect(state(tester).play!.tries.length,
            lessThanOrEqualTo(board.inside));
        expect(find.text('Open'), findsOne);
      }
    });
  });

  group('the rows on screen', () {
    testWidgets('there is one for every guess the lock allows',
        (tester) async {
      await open(tester, which: 0, marks: gate);
      // Five rows of four pegs, and the six colours to choose from.
      expect(pegsOnScreen(tester), 5 * 4 + 6);
      await open(tester, which: 1, marks: Marks.of(Boards.at(1).lock));
      expect(pegsOnScreen(tester), 6 * 5 + 5);
    });

    testWidgets('and another lock sets a fresh one', (tester) async {
      await open(tester, which: 0, marks: gate, secret: 12);
      await tryCode(tester, Boards.at(0).lock.pegsOf(12));
      expect(state(tester).play!.isOpen, isTrue);

      await press(tester, 'Another lock');
      expect(state(tester).play!.tries, isEmpty);
      expect(state(tester).play!.left, 5);
      expect(state(tester).play!.isOver, isFalse);
    });
  });
}

/// The largest group a guess could leave behind, worked out by hand.
int _worstFor(Marks marks, could, int guess) {
  final counts = <int, int>{};
  for (final code in could) {
    final mark = marks.at(code, guess);
    counts[mark] = (counts[mark] ?? 0) + 1;
  }
  return counts.values.reduce((a, b) => a > b ? a : b);
}
