import 'package:flutter_test/flutter_test.dart';
import 'package:hollowmarch/pegs/boards.dart';
import 'package:hollowmarch/pegs/field.dart';
import 'package:hollowmarch/pegs/guide.dart';
import 'package:hollowmarch/pegs/play.dart';
import 'package:hollowmarch/pegs/rule_of_three.dart';
import 'package:hollowmarch/pegs/runs.dart';
import 'package:hollowmarch/pegs/solve.dart';

void main() {
  group('the shape of a board', () {
    test('counts its hollows and leaves out the corners', () {
      final field = Field(const ['#.#', '...', '#.#']);
      expect(field.hollows, 5);
      expect(field.isHollow(0, 0), isFalse);
      expect(field.isHollow(1, 1), isTrue);
      expect(field.at(0, 0), -1);
    });

    test('and knows every jump the shape allows, both ways round', () {
      final field = Field(const ['...']);
      expect(field.jumps, hasLength(2));
      expect(field.jumps, contains(const Jump(0, 1, 2)));
      expect(field.jumps, contains(const Jump(2, 1, 0)));
    });

    test('and no jump that runs off the board', () {
      final field = Field(const ['#.#', '...', '#.#']);
      for (final jump in field.jumps) {
        expect(jump.from, inInclusiveRange(0, field.hollows - 1));
        expect(jump.over, inInclusiveRange(0, field.hollows - 1));
        expect(jump.to, inInclusiveRange(0, field.hollows - 1));
      }
      expect(field.jumps, hasLength(4));
    });
  });

  group('the rule of three', () {
    test('does not change when a peg jumps, on any board, any jump', () {
      // The whole claim. If this ever failed, everything else here that
      // rules a finish out would be ruling it out for no reason.
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        final field = board.field;
        final rule = RuleOfThree(field);

        // A hundred positions reached by playing at random, and every jump
        // available from each of them.
        var pegs = board.start;
        for (var step = 0; step < 100; step++) {
          final was = rule.of(pegs);
          final could = Solver.jumpsIn(field, pegs);
          for (final jump in could) {
            expect(rule.of(Solver.after(pegs, jump)), was,
                reason: '${board.name}: $jump changed the sums');
          }
          if (could.isEmpty) break;
          pegs = Solver.after(pegs, could[step % could.length]);
        }
      }
    });

    test('and says a board can only ever come down to a hollow it agrees with',
        () {
      // Where the search finds a finish, the rule must have allowed it. The
      // other way round is not claimed and is not true: the rule allows
      // hollows the pegs cannot reach.
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        if (board.hollows > 20) continue;
        final field = board.field;
        final rule = RuleOfThree(field);
        final allowed = rule.couldFinish(board.start);

        final route = Solver(field).from(board.start)!;
        expect(allowed, contains(route.jumps.last.to), reason: board.name);
      }
    });

    test('and on the central game it allows exactly five hollows', () {
      // The old result about this board, worked out here from the sums
      // rather than looked up: from the middle, the last peg can only be in
      // the middle or at the end of one of the four arms.
      final board = Boards.at(Boards.count - 1);
      final field = board.field;
      expect(field.hollows, 33);

      final allowed = RuleOfThree(field).couldFinish(board.start);
      expect(
        allowed.map((h) => (field.rowOf(h), field.columnOf(h))).toSet(),
        {(0, 3), (3, 0), (3, 3), (3, 6), (6, 3)},
      );
    });

    test('and every one of those five can really be reached', () {
      // The rule says at most those five. The search says at least those
      // five. Between them there is nothing left to wonder about.
      //
      // Four of the five take millions of positions to find, so this checks
      // the two the search settles quickly and `make prove` does the rest.
      final board = Boards.at(Boards.count - 1);
      final field = board.field;
      for (final where in const [(3, 3), (6, 3)]) {
        final hollow = field.at(where.$1, where.$2);
        final route = Solver(field, finishAt: hollow).from(board.start);
        expect(route, isNotNull, reason: 'cannot finish at $where');
        expect(route!.jumps.last.to, hollow);
        expect(route.jumps, hasLength(31), reason: 'a jump takes one peg');
      }
    });
  });

  group('every board', () {
    test('can be brought down to one peg', () {
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        final route = Solver(board.field).from(board.start);
        expect(route, isNotNull, reason: board.name);
        expect(route!.jumps, hasLength(board.hollows - 2),
            reason: '${board.name}: every jump takes exactly one peg off');
      }
    });

    test('and the par on it is the fewest moves there are', () {
      // Worked out again from nothing, not read off the board. A par that is
      // one out is worse than no par at all: it asks for something that
      // cannot be done, or lets a longer way through as if it were the best.
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        if (board.par == null) continue;
        final fewest = Runs.fewest(board.field, board.start);
        expect(fewest, isNotNull, reason: board.name);
        expect(fewest!.$1, board.par, reason: board.name);
        expect(Runs.movesIn(fewest.$2), board.par, reason: board.name);
      }
    });

    test('and the big one says nothing it cannot prove', () {
      // Nothing here can walk the positions of the 33 hollow board, so it
      // ships without a par rather than with a guess.
      final board = Boards.at(Boards.count - 1);
      expect(board.hollows, 33);
      expect(board.par, isNull);
    });

    test('and starts with one hollow empty', () {
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        expect(Solver.count(board.start), board.hollows - 1,
            reason: board.name);
        expect(board.field.isHollow(board.empty.$1, board.empty.$2), isTrue,
            reason: '${board.name} starts empty at a square that is not on it');
      }
    });
  });

  group('playing', () {
    Play start([int which = 0]) => Play.of(Boards.at(which));

    test('begins full but for one hollow', () {
      final play = start();
      expect(play.left, play.field.hollows - 1);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
      expect(play.isStuck, isFalse);
    });

    test('jumps a peg two along, taking what it passed over', () {
      final play = start();
      final field = play.field;
      final from = field.at(0, 2);
      final over = field.at(0, 1);
      final to = field.at(0, 0);

      expect(play.canGo(from, to), isTrue);
      final after = play.jump(from, to);
      expect(after.has(from), isFalse);
      expect(after.has(over), isFalse, reason: 'and takes the one it passed');
      expect(after.has(to), isTrue);
      expect(after.left, play.left - 1);
      expect(after.moves, 1);
    });

    test('and refuses everything that is not a jump, with a reason', () {
      final play = start();
      final field = play.field;

      expect(play.whyNot(field.at(0, 1), field.at(0, 3)), Refusal.taken);
      expect(play.whyNot(field.at(1, 1), field.at(1, 3)), Refusal.taken);
      expect(play.whyNot(field.at(0, 0), field.at(0, 2)), Refusal.noPeg);
      expect(play.whyNot(field.at(2, 0), field.at(1, 1)), Refusal.notAJump,
          reason: 'across a corner');
      expect(play.whyNot(field.at(0, 1), field.at(0, 2)), Refusal.notAJump,
          reason: 'the square next door is not a jump');

      final one = play.jump(field.at(0, 2), field.at(0, 0));
      expect(one.whyNot(field.at(0, 0), field.at(0, 2)),
          Refusal.nothingToTake);
      expect(Refusal.notAJump.says, contains('two hollows'));
    });

    test('counts a run of jumps by one peg as one move', () {
      // The whole reason the count is worth anything. The fewest way through
      // the first board is ten jumps in six moves, so four of those jumps
      // are a peg carrying on — and playing it out has to come to six.
      final board = Boards.at(0);
      final fewest = Runs.fewest(board.field, board.start)!;
      expect(fewest.$1, board.par);
      expect(fewest.$2.length, board.hollows - 2);

      var play = Play.of(board);
      var runs = 0;
      for (final jump in fewest.$2) {
        if (play.carrying != jump.from) {
          play = play.letGo;
          runs++;
        }
        play = play.jump(jump.from, jump.to);
        expect(play.jumps.last, jump, reason: 'the jump was refused');
      }
      expect(runs, board.par);
      expect(play.moves, board.par);
      expect(play.isDone, isTrue);
    });

    test('and lets nothing else move while a peg is part way through one', () {
      final board = Boards.at(0);
      final fewest = Runs.fewest(board.field, board.start)!.$2;
      var play = Play.of(board);

      // Up to the first jump that carries on from where the last one landed.
      var at = 0;
      while (at + 1 < fewest.length && fewest[at + 1].from != fewest[at].to) {
        play = play.letGo.jump(fewest[at].from, fewest[at].to);
        at++;
      }
      play = play.letGo.jump(fewest[at].from, fewest[at].to);
      expect(play.carrying, fewest[at].to);

      expect(play.canJump.every((jump) => jump.from == play.carrying), isTrue);
      final other = Solver.jumpsIn(play.field, play.pegs)
          .firstWhere((jump) => jump.from != play.carrying);
      expect(play.whyNot(other.from, other.to), Refusal.notThatPeg);

      final was = play.moves;
      play = play.jump(fewest[at + 1].from, fewest[at + 1].to);
      expect(play.moves, was, reason: 'still the same peg, still one move');
    });

    test('takes a jump back, and back into the middle of a run', () {
      final board = Boards.at(0);
      final fewest = Runs.fewest(board.field, board.start)!.$2;
      var play = Play.of(board);
      var at = 0;
      while (at + 1 < fewest.length && fewest[at + 1].from != fewest[at].to) {
        play = play.letGo.jump(fewest[at].from, fewest[at].to);
        at++;
      }
      play = play.letGo.jump(fewest[at].from, fewest[at].to);
      play = play.jump(fewest[at + 1].from, fewest[at + 1].to);
      final deep = play.left;

      play = play.back;
      expect(play.left, deep + 1);
      expect(play.carrying, fewest[at].to,
          reason: 'back into the run it came out of');

      while (play.jumps.isNotEmpty) {
        play = play.back;
      }
      expect(play.left, board.hollows - 1);
      expect(play.carrying, -1);
      expect(play.back.jumps, isEmpty, reason: 'and stops at the start');
    });

    test('knows when it is stuck, and when it is finished', () {
      // A board played out to one peg by following the answer.
      final board = Boards.at(0);
      var play = Play.of(board);
      for (final jump in Solver(board.field).from(board.start)!.jumps) {
        play = play.letGo.jump(jump.from, jump.to);
      }
      expect(play.isDone, isTrue);
      expect(play.left, 1);
      expect(play.isStuck, isFalse, reason: 'finished is not stuck');
    });

    test('and a board that has gone wrong is stuck rather than finished', () {
      // The plus of five: whatever is done first, it stops with three pegs.
      final board = const Board(
        name: 'plus',
        rows: ['#.#', '...', '#.#'],
        empty: (0, 1),
      );
      final field = board.field;
      var play = Play.of(board);
      play = play.jump(field.at(2, 1), field.at(0, 1));
      expect(play.isDone, isFalse);
      expect(play.isStuck, isTrue);
      expect(play.left, 3);
    });
  });

  group('a guide', () {
    test('says a finished-off board can no longer be finished', () {
      final board = const Board(
        name: 'plus',
        rows: ['#.#', '...', '#.#'],
        empty: (0, 1),
      );
      final field = board.field;
      final guide = Guide(board);
      final play = Play.of(board).jump(field.at(2, 1), field.at(0, 1));

      expect(play.isStuck, isTrue);
      expect(guide.canStillFinish(play.pegs), isFalse);
    });

    test('and the sums alone settle some of them, without any searching', () {
      // What the rule of three is worth: positions it rules out cost two
      // sums rather than a search, and on the boards here that is most of
      // the dead ones.
      final board = Boards.at(0);
      final guide = Guide(board);
      final field = board.field;

      var settled = 0;
      var looked = 0;
      // Every position two pegs apart from the end, which is where a game
      // that has gone wrong ends up.
      for (var a = 0; a < field.hollows; a++) {
        for (var b = a + 1; b < field.hollows; b++) {
          looked++;
          if (guide.couldFinish((1 << a) | (1 << b)).isEmpty) settled++;
        }
      }
      expect(settled, greaterThanOrEqualTo(looked ~/ 2),
          reason: 'the sums settled $settled of $looked');
    });

    test('and points at a jump that keeps a board alive', () {
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        final guide = Guide(board);
        final play = Play.of(board);

        final next = guide.next(play);
        expect(next, isNotNull, reason: board.name);
        expect(play.canGo(next!.from, next.to), isTrue, reason: board.name);
        expect(guide.canStillFinish(play.jump(next.from, next.to).pegs),
            isTrue, reason: board.name);
      }
    });

    test('and follows itself down to one peg', () {
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        final guide = Guide(board);
        var play = Play.of(board);

        var guard = 0;
        while (!play.isDone && guard++ < 60) {
          final next = guide.next(play.letGo);
          expect(next, isNotNull, reason: board.name);
          play = play.letGo.jump(next!.from, next.to);
        }
        expect(play.isDone, isTrue, reason: board.name);
      }
    });

    test('and says it cannot see rather than guessing', () {
      // Given almost nothing to look at, the search has to say so — a "no"
      // it has not earned would tell somebody to take back a move that was
      // perfectly good.
      final board = Boards.at(Boards.count - 1);
      final guide = Guide(board, give: 5);
      final play = Play.of(board).letGo;
      // A first jump that really is on a way down, so the truth is "yes".
      final good = Guide(board).next(play)!;
      expect(guide.canStillFinish(play.jump(good.from, good.to).pegs), isNull);
    });
  });
}
