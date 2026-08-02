import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lockstead/lock/boards.dart';
import 'package:lockstead/lock/lock.dart';
import 'package:lockstead/lock/marks.dart';
import 'package:lockstead/lock/play.dart';
import 'package:lockstead/lock/solver.dart';

void main() {
  const gate = Lock(pegs: 4, colours: 6);

  group('a lock', () {
    test('has as many codes as there are ways to fill it', () {
      expect(gate.codes, 1296);
      expect(const Lock(pegs: 5, colours: 5).codes, 3125);
    });

    test('turns a code into pegs and back again', () {
      for (final pegs in const [
        [0, 0, 0, 0],
        [5, 4, 3, 2],
        [1, 1, 5, 0],
      ]) {
        expect(gate.pegsOf(gate.codeOf(pegs)), pegs);
      }
    });
  });

  group('marking a guess', () {
    Mark mark(List<int> code, List<int> guess) =>
        gate.markOf(gate.codeOf(code), gate.codeOf(guess));

    test('counts the pegs that are right where they are', () {
      expect(mark([0, 1, 2, 3], [0, 1, 2, 3]), const Mark(4, 0));
      expect(mark([0, 1, 2, 3], [0, 1, 4, 5]), const Mark(2, 0));
    });

    test('counts a colour in the wrong place, once', () {
      expect(mark([0, 1, 2, 3], [3, 2, 1, 0]), const Mark(0, 4));
      expect(mark([0, 1, 2, 3], [1, 0, 4, 5]), const Mark(0, 2));
    });

    test('and gets repeated colours right, which is the whole difficulty', () {
      // The code has one red; the guess has three. One of them can be
      // credited and no more, however many are offered.
      expect(mark([0, 1, 2, 3], [0, 0, 0, 0]), const Mark(1, 0));
      expect(mark([0, 0, 0, 0], [0, 1, 2, 3]), const Mark(1, 0));
      // Two in the code, two in the guess, neither in the right place.
      expect(mark([0, 0, 1, 1], [1, 1, 0, 0]), const Mark(0, 4));
      // Two in the code, three in the guess: two whites, not three.
      expect(mark([1, 0, 0, 2], [0, 0, 0, 3]), const Mark(2, 0));
      expect(mark([0, 0, 1, 2], [3, 0, 0, 0]), const Mark(1, 1));
    });

    test('never says everything but one right with one in the wrong place', () {
      // There is nowhere for the odd peg to go, so that mark cannot happen.
      // A game that offers it as a possible answer is a game that can lie.
      final dice = Random(3);
      for (var i = 0; i < 4000; i++) {
        final got = gate.markOf(
          dice.nextInt(gate.codes),
          dice.nextInt(gate.codes),
        );
        expect(got.blacks == gate.pegs - 1 && got.whites == 1, isFalse);
      }
      expect(gate.everyMark, isNot(contains(const Mark(3, 1))));
    });

    test('is the same whichever way round it is asked', () {
      final dice = Random(11);
      for (var i = 0; i < 3000; i++) {
        final a = dice.nextInt(gate.codes);
        final b = dice.nextInt(gate.codes);
        expect(gate.markOf(a, b), gate.markOf(b, a));
      }
    });
  });

  group('the table', () {
    late Marks marks;

    setUpAll(() => marks = Marks.of(gate));

    test('says what marking says', () {
      final dice = Random(5);
      for (var i = 0; i < 20000; i++) {
        final code = dice.nextInt(gate.codes);
        final guess = dice.nextInt(gate.codes);
        expect(marks.at(code, guess), gate.markOf(code, guess).asOne(gate));
      }
    });

    test('narrows a set to what is still possible, and nothing else', () {
      // What the player knows after a guess: the codes that would have come
      // back the same way. Checked against marking each one by hand.
      final dice = Random(9);
      for (var i = 0; i < 40; i++) {
        final guess = dice.nextInt(gate.codes);
        final mark = gate.markOf(dice.nextInt(gate.codes), guess);
        final kept = marks.narrow(marks.everything, guess, mark.asOne(gate));

        var counted = 0;
        for (var code = 0; code < gate.codes; code++) {
          if (gate.markOf(code, guess) == mark) counted++;
        }
        expect(kept.length, counted);
        for (final code in kept) {
          expect(gate.markOf(code, guess), mark);
        }
      }
    });
  });

  group('every board', () {
    test('opens in the number of guesses it promises, for every code', () {
      // The claim the game is sold on. The strategy is a tree — one guess at
      // the top, a branch for every mark it can come back with, the same
      // question down each branch — and every code in the lock is a leaf of
      // it. So walking it once answers for all of them, and the deepest leaf
      // is the promise.
      for (final board in Boards.all) {
        final depths = Solver(Marks.of(board.lock)).deepest();
        expect(depths.deepest, board.inside,
            reason: '${board.name} says ${board.inside} and takes '
                '${depths.deepest}');
        expect(depths.codes, board.codes,
            reason: '${board.name} left some codes out of the tree');
      }
    });

    test('and the garden gate is the famous one, which takes five', () {
      // Four pegs and six colours picked in five guesses is a known result
      // from 1976, and it is the one number here that can be checked against
      // somebody else's work.
      expect(Boards.at(0).lock.pegs, 4);
      expect(Boards.at(0).lock.colours, 6);
      expect(Boards.at(0).inside, 5);
    });
  });

  group('a game', () {
    late Marks marks;

    setUpAll(() => marks = Marks.of(gate));

    test('starts with everything possible and nothing tried', () {
      final play = Play.of(Boards.at(0), marks, secret: 100);
      expect(play.could.length, 1296);
      expect(play.tries, isEmpty);
      expect(play.left, 5);
      expect(play.isOver, isFalse);
    });

    test('marks a guess and narrows what is left', () {
      final play = Play.of(Boards.at(0), marks, secret: gate.codeOf([0, 1, 2, 3]))
          .tried(gate.codeOf([0, 0, 1, 1]));

      expect(play.tries.single.mark, const Mark(1, 1));
      expect(play.could.length, lessThan(1296));
      expect(play.could, contains(gate.codeOf([0, 1, 2, 3])),
          reason: 'the code itself must always still be possible');
      expect(play.left, 4);
    });

    test('is open when every peg is right', () {
      final play = Play.of(Boards.at(0), marks, secret: 77).tried(77);
      expect(play.isOpen, isTrue);
      expect(play.isOver, isTrue);
      expect(play.could.length, 1);
    });

    test('is lost when the guesses run out', () {
      var play = Play.of(Boards.at(0), marks, secret: 0);
      for (var i = 0; i < 5; i++) {
        play = play.tried(1 + i);
      }
      expect(play.isLost, isTrue);
      expect(play.isOpen, isFalse);
      expect(play.tried(0).tries, hasLength(5),
          reason: 'nothing happens after it is over');
    });

    test('and the code is always among what is still possible', () {
      // The one thing that would make the game a cheat: a set of possibles
      // that has ruled out the answer. Played against every guess the solver
      // would make, for a hundred codes.
      final solver = Solver(marks);
      final dice = Random(21);
      for (var i = 0; i < 100; i++) {
        var play = Play.of(Boards.at(0), marks, secret: dice.nextInt(1296));
        while (!play.isOver) {
          expect(play.could, contains(play.secret));
          play = play.tried(solver.best(play.could).guess);
        }
        expect(play.isOpen, isTrue,
            reason: 'the solver failed to open it in five');
      }
    });
  });
}
