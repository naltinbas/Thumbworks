import 'package:flutter_test/flutter_test.dart';
import 'package:smithwaite/forge/fewest.dart';
import 'package:smithwaite/forge/play.dart';
import 'package:smithwaite/forge/puzzles.dart';

void main() {
  group('the cords', () {
    test('the first ring moves whenever it likes', () {
      for (var state = 0; state < 8; state++) {
        expect(Moves.mayMove(3, state, 0), isTrue);
      }
    });

    test('any other ring needs the one before it on and the rest off', () {
      // Ring 2 with rings 0..1 lying every way: only 0b?10 allows it.
      expect(Moves.mayMove(3, 2, 2), isTrue);
      expect(Moves.mayMove(3, 6, 2), isTrue);
      expect(Moves.mayMove(3, 0, 2), isFalse);
      expect(Moves.mayMove(3, 1, 2), isFalse);
      expect(Moves.mayMove(3, 3, 2), isFalse);
    });
  });

  group('the walk', () {
    test('reaches every state there is', () {
      for (final rings in const [3, 5, 7]) {
        final far = Moves.walk(rings);
        expect(far.length, 1 << rings);
        expect(far.where((away) => away < 0), isEmpty);
      }
    });

    test('the whole puzzle is a single path: two ends, two moves everywhere '
        'else', () {
      // The fact that makes the game what it is, counted rather than said.
      for (final rings in const [4, 6, 8]) {
        var ends = 0;
        for (var state = 0; state < (1 << rings); state++) {
          final ways = Moves.moves(rings, state).length;
          expect(ways, inInclusiveRange(1, 2), reason: 'state $state');
          if (ways == 1) ends++;
        }
        expect(ends, 2, reason: '$rings rings');
      }
    });

    test('and the two ends are the freed bar and the lone top ring', () {
      for (final rings in const [4, 6]) {
        expect(Moves.moves(rings, 0).length, 1);
        expect(Moves.moves(rings, 1 << (rings - 1)).length, 1);
      }
    });
  });

  group('the smith and the walk', () {
    test('agree on every state of three to nine rings', () {
      // The anchor. The walk plays the toy; the smith reads the rings as a
      // Gray code and decodes. They never part.
      for (var rings = 3; rings <= 9; rings++) {
        final far = Moves.walk(rings);
        for (var state = 0; state < (1 << rings); state++) {
          expect(far[state], Moves.bySmith(rings, state),
              reason: '$rings rings, state $state');
        }
      }
    });

    test('the farthest state is the lone top ring, at all-ones distance', () {
      for (final rings in const [4, 5, 6]) {
        final far = Moves.walk(rings);
        var farthest = 0;
        for (var state = 0; state < (1 << rings); state++) {
          if (far[state] > far[farthest]) farthest = state;
        }
        expect(farthest, 1 << (rings - 1));
        expect(far[farthest], (1 << rings) - 1);
      }
    });

    test('and every move changes the count by exactly one', () {
      final far = Moves.walk(6);
      for (var state = 0; state < (1 << 6); state++) {
        for (final other in Moves.moves(6, state)) {
          expect((far[state] - far[other]).abs(), 1,
              reason: '$state to $other');
        }
      }
    });
  });

  group('every puzzle that ships', () {
    for (var number = 0; number < Puzzles.count; number++) {
      final puzzle = Puzzles.at(number);

      test('${puzzle.name} says what the walk and the smith say', () {
        expect(Moves.walk(puzzle.rings)[puzzle.start], puzzle.fewest);
        expect(Moves.bySmith(puzzle.rings, puzzle.start), puzzle.fewest);
      });
    }

    test('the tangle is farther than the whole puzzle', () {
      expect(Puzzles.at(3).fewest, greaterThan(Puzzles.at(2).fewest));
      expect(Puzzles.at(3).rings, Puzzles.at(2).rings);
    });
  });

  group('a puzzle in hand', () {
    test('starts as handed over, with the fewest still to be had', () {
      final play = Play.of(Puzzles.at(0));
      expect(play.made, 0);
      expect(play.isFree, isFalse);
      expect(play.couldStillBe, Puzzles.at(0).fewest);
      expect(play.smithSays, Puzzles.at(0).fewest);
    });

    test('a ring the cords hold cannot move', () {
      final play = Play.of(Puzzles.at(0));
      // All on: ring 2 may not move, its before-rings are not a lone one.
      expect(play.mayMove(0), isTrue);
      expect(play.mayMove(1), isTrue);
      expect(play.mayMove(2), isFalse);
      expect(identical(play.move(2), play), isTrue);
    });

    test('following next frees every puzzle at its fewest', () {
      for (var number = 0; number < Puzzles.count; number++) {
        final puzzle = Puzzles.at(number);
        var play = Play.of(puzzle);
        var guard = 0;
        while (!play.isFree) {
          if (guard++ > 90) fail('${puzzle.name} never freed');
          expect(play.couldStillBe, puzzle.fewest, reason: puzzle.name);
          play = play.move(play.next!);
        }
        expect(play.made, puzzle.fewest, reason: puzzle.name);
        expect(play.isFewest, isTrue, reason: puzzle.name);
      }
    });

    test('the one wrong move costs exactly two, and shows at once', () {
      // At most two moves and one goes forward, so the wrong one is the
      // step back: one move spent, one move farther.
      var play = Play.of(Puzzles.at(2));
      play = play.move(play.next!);
      play = play.move(play.next!);
      final wrong = [
        for (var ring = 0; ring < play.puzzle.rings; ring++)
          if (play.mayMove(ring) && ring != play.next) ring,
      ];
      expect(wrong, hasLength(1));
      expect(play.move(wrong.single).couldStillBe,
          play.puzzle.fewest + 2);
    });

    test('take back returns the rings as they lay', () {
      final start = Play.of(Puzzles.at(0));
      final moved = start.move(start.next!);
      expect(moved.made, 1);
      expect(moved.back.state, Puzzles.at(0).start);
      expect(identical(start.back, start), isTrue);
    });

    test('the smith reads the rings as they lie, all the way down', () {
      var play = Play.of(Puzzles.at(0));
      while (!play.isFree) {
        expect(play.smithSays, play.couldStillBe - play.made);
        play = play.move(play.next!);
      }
      expect(play.smithSays, 0);
    });
  });
}
