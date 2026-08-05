import 'package:flutter_test/flutter_test.dart';
import 'package:skeinmoor/thread/boards.dart';
import 'package:skeinmoor/thread/field.dart';
import 'package:skeinmoor/thread/guide.dart';
import 'package:skeinmoor/thread/play.dart';
import 'package:skeinmoor/thread/solve.dart';

void main() {
  group('reading a board', () {
    test('pairs the letters up into the ends of threads', () {
      final field = Field.picture(const ['a.b', '...', 'b.a']);
      expect(field.across, 3);
      expect(field.down, 3);
      expect(field.threads, 2);
      expect(field.ends[0], (0, 8), reason: 'the two a');
      expect(field.ends[1], (2, 6), reason: 'the two b');
    });

    test('and knows which cells touch', () {
      final field = Field.picture(const ['a.b', '...', 'b.a']);
      expect(field.touching(0, 1), isTrue);
      expect(field.touching(0, 3), isTrue);
      expect(field.touching(0, 4), isFalse, reason: 'corners do not touch');
      expect(field.touching(2, 3), isFalse, reason: 'nor across a row');
    });
  });

  group('filling a board', () {
    test('finds the way through a small one', () {
      // Two threads down a two by two: a on the left, b on the right.
      final found = Threader(Field.picture(const ['ab', 'ab'])).ways(enough: 5);
      expect(found.count, 1);
      expect(found.first, [
        [0, 2],
        [1, 3],
      ]);
    });

    test('says so when a board cannot be filled at all', () {
      // Colour a three by three like a draughts board and there are five
      // dark cells and four light. A thread between two dark cells covers
      // one more dark than light, so two of them cover two more — six dark
      // out of five. It cannot be done, and no search is needed to know it.
      final found =
          Threader(Field.picture(const ['a.b', '...', 'a.b'])).ways(enough: 5);
      expect(found.canBeDone, isFalse);
    });

    test('counts a board with room to wander as having several ways', () {
      // One thread from corner to corner of a three by three can go round
      // either way, and both ways fill the board. That is a board nobody
      // should be given.
      final found =
          Threader(Field.picture(const ['a..', '...', '..a'])).ways(enough: 9);
      expect(found.count, greaterThan(1));
    });

    test('and what it gives back is a real way of filling the board', () {
      for (var i = 0; i < Boards.count; i++) {
        final board = Boards.at(i);
        final field = board.field;
        final answer = Threader(field).ways().first!;
        final owner = List.filled(field.cells, -1);

        expect(answer.length, field.threads, reason: board.name);
        for (var thread = 0; thread < field.threads; thread++) {
          final path = answer[thread];
          expect(path.first, field.ends[thread].$1, reason: board.name);
          expect(path.last, field.ends[thread].$2, reason: board.name);

          for (var step = 0; step < path.length; step++) {
            if (step > 0) {
              expect(field.touching(path[step - 1], path[step]), isTrue,
                  reason: '${board.name}: thread $thread jumps');
            }
            expect(owner[path[step]], -1,
                reason: '${board.name}: two threads on one cell');
            owner[path[step]] = thread;
          }
        }
        expect(owner, isNot(contains(-1)),
            reason: '${board.name} was left with an empty cell');
      }
    });
  });

  group('every board', () {
    test('has exactly one way of being filled', () {
      // The whole design. Two ways and a guess can be as right as a reason.
      for (var i = 0; i < Boards.count; i++) {
        final board = Boards.at(i);
        final found = Threader(board.field).ways(enough: 3);
        expect(found.count, 1,
            reason: '${board.name} has ${found.count} ways of being filled');
      }
    });

    test('is square, with both ends of every thread on it and nothing else',
        () {
      for (var i = 0; i < Boards.count; i++) {
        final board = Boards.at(i);
        expect(board.rows.every((row) => row.length == board.side), isTrue,
            reason: '${board.name} is not square');
        expect(board.threads, greaterThan(2), reason: board.name);

        final letters = board.rows.join().split('')
          ..removeWhere((c) => c == '.');
        for (final letter in letters.toSet()) {
          expect(letters.where((c) => c == letter).length, 2,
              reason: '${board.name} has an odd number of $letter');
        }
      }
    });

    test('and no thread that joins itself the moment it opens', () {
      // Four cells is the shortest thread worth drawing. Anything less and
      // the board has one fewer thing to work out on it.
      for (var i = 0; i < Boards.count; i++) {
        final board = Boards.at(i);
        final answer = Threader(board.field).ways().first!;
        for (var thread = 0; thread < board.threads; thread++) {
          expect(answer[thread].length, greaterThanOrEqualTo(4),
              reason: '${board.name}: thread $thread is a corner');
        }
      }
    });
  });

  group('drawing a thread', () {
    const small = Board(name: 'test', rows: ['a.b', '...', 'a.b']);

    test('starts at one end of each, with the rest empty', () {
      final play = Play.of(Boards.at(0));
      expect(play.filled, play.field.threads * 2);
      expect(play.isDone, isFalse);
      for (var thread = 0; thread < play.field.threads; thread++) {
        expect(play.pathOf(thread), [play.field.ends[thread].$1]);
        expect(play.isJoined(thread), isFalse);
      }
    });

    test('goes to a cell it touches, and not to one it does not', () {
      final play = Play.of(small);
      expect(play.canGoTo(0, 3), isTrue);
      expect(play.goTo(0, 3).ownerOf(3), 0);

      expect(play.canGoTo(0, 4), isFalse, reason: 'across a corner');
      expect(play.whyNot(0, 4), contains('one cell at a time'));
      expect(play.goTo(0, 4).filled, play.filled);
    });

    test('and not off the board', () {
      final play = Play.of(Boards.at(0));
      expect(play.canGoTo(0, -1), isFalse);
      expect(play.canGoTo(0, 9999), isFalse);
    });

    test('and not onto somebody else’s end', () {
      final play = Play.of(const Board(name: 'test', rows: ['ab.', '...', 'ab.']));
      expect(play.canGoTo(0, 1), isFalse, reason: 'that is b');
      expect(play.whyNot(0, 1), contains('ends stay where they are'));
    });

    test('rubs itself back a cell at a time', () {
      final drawn = Play.of(small).goTo(0, 3);

      expect(drawn.back(0).ownerOf(3), -1);
      expect(drawn.back(0).pathOf(0), hasLength(1));
      expect(drawn.back(0).back(0).pathOf(0), hasLength(1),
          reason: 'and stops at the end it started from');
      expect(drawn.clear(0).pathOf(0), hasLength(1));
    });

    test('and comes back to a cell it has already been through', () {
      // A finger dragged back over its own line shortens it, rather than
      // doing nothing or rubbing the lot out.
      var play = Play.of(small).draw(0, 3).draw(0, 4).draw(0, 5);
      expect(play.pathOf(0), [0, 3, 4, 5]);

      play = play.draw(0, 3);
      expect(play.pathOf(0), [0, 3], reason: 'back to the cell touched');
      expect(play.ownerOf(4), -1);
      expect(play.ownerOf(5), -1);
    });

    test('cuts another thread back when it takes a cell from it', () {
      // What everybody expects from a game of this shape: the newer line
      // wins and the older one gets out of the way, back to where they met.
      var play = Play.of(small);

      play = play.goTo(0, 3).goTo(0, 4);
      expect(play.ownerOf(4), 0);

      play = play.goTo(1, 5).goTo(1, 4);
      expect(play.ownerOf(4), 1, reason: 'the newer thread has it');
      expect(play.pathOf(0), [0, 3],
          reason: 'and the older one was cut back to where they met');
    });

    test('and can be drawn from either end', () {
      // A thread joins two ends and neither of them is the first one, so
      // grabbing the far one turns it round rather than doing nothing.
      var play = Play.of(small);
      expect(play.fromOf(0), 0);

      play = play.startFrom(0, 6);
      expect(play.fromOf(0), 6);
      expect(play.toOf(0), 0);
      expect(play.pathOf(0), [6]);

      play = play.draw(0, 3).draw(0, 0);
      expect(play.isJoined(0), isTrue);
    });

    test('and starting from an end again rubs out what was there', () {
      var play = Play.of(small).draw(0, 3).draw(0, 4);
      expect(play.filled, 6);

      play = play.startFrom(0, 0);
      expect(play.pathOf(0), [0]);
      expect(play.ownerOf(3), -1);
      expect(play.ownerOf(4), -1);
    });

    test('is joined when it reaches its other end', () {
      final play = Play.of(const Board(name: 'test', rows: ['a.a', '...']))
          .goTo(0, 1)
          .goTo(0, 2);
      expect(play.isJoined(0), isTrue);
      expect(play.canGoTo(0, 5), isFalse, reason: 'and goes no further');
      expect(play.whyNot(0, 5), contains('joined up already'));
    });

    test('and the board is finished only when nothing is left over', () {
      // Joining every thread is not enough: the cells left over are the
      // puzzle.
      final play = Play.of(const Board(name: 'test', rows: ['a.a', '...']))
          .goTo(0, 1)
          .goTo(0, 2);
      expect(play.joined, 1);
      expect(play.empty, 3);
      expect(play.isDone, isFalse, reason: 'three cells are still empty');
    });

    test('and every board can be filled by following the answer', () {
      // Every board played out cell by cell through the same code a finger
      // goes through, and finished.
      for (var which = 0; which < Boards.count; which++) {
        final board = Boards.at(which);
        final guide = Guide.of(board);
        var play = Play.of(board);

        for (var step = guide.next(play);
            step != null;
            step = guide.next(play)) {
          expect(step.wrong, isFalse, reason: board.name);
          expect(play.canGoTo(step.thread, step.at), isTrue,
              reason: '${board.name}: the answer asks for a step it cannot '
                  'make');
          play = play.goTo(step.thread, step.at);
        }
        expect(play.isDone, isTrue, reason: board.name);
      }
    });
  });

  group('a hint', () {
    test('points at the next cell of the answer', () {
      final board = Boards.at(0);
      final guide = Guide.of(board);
      final play = Play.of(board);

      final step = guide.next(play)!;
      expect(step.wrong, isFalse);
      expect(step.at, guide.answer[step.thread][1]);
      expect(guide.left(play), greaterThan(0));
    });

    test('and at a cell to rub out when a thread has wandered off', () {
      final board = Boards.at(0);
      final guide = Guide.of(board);
      var play = Play.of(board);

      // Somewhere the answer does not go: a first step, for whichever thread
      // has one, that is not the step the answer takes.
      var thread = -1;
      var other = -1;
      for (var t = 0; t < play.field.threads && thread < 0; t++) {
        for (var way = 0; way < 4; way++) {
          final at = play.field.beside(play.headOf(t), way);
          if (play.canGoTo(t, at) && at != guide.answer[t][1]) {
            thread = t;
            other = at;
            break;
          }
        }
      }
      expect(thread, isNonNegative, reason: 'no wrong first step to make');

      play = play.goTo(thread, other);
      expect(guide.isRight(play, thread), isFalse);

      final step = guide.next(play)!;
      expect(step.wrong, isTrue);
      expect(step.thread, thread);
      expect(step.at, other);
    });

    test('and has nothing to say about a board that is finished', () {
      final board = Boards.at(0);
      final guide = Guide.of(board);
      var play = Play.of(board);
      for (var step = guide.next(play); step != null; step = guide.next(play)) {
        play = play.goTo(step.thread, step.at);
      }
      expect(guide.next(play), isNull);
      expect(guide.left(play), 0);
    });
  });
}
