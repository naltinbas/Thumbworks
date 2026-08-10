import 'package:flutter_test/flutter_test.dart';
import 'package:staddlestone/mill/fewest.dart';
import 'package:staddlestone/mill/play.dart';
import 'package:staddlestone/mill/yard.dart';
import 'package:staddlestone/mill/yards.dart';

void main() {
  group('the standing', () {
    test('knows the top stone of each staddle', () {
      final standing = Standing([0, 1, 0]);
      expect(standing.topOf(0), 0);
      expect(standing.topOf(1), 1);
      expect(standing.topOf(2), -1);
    });

    test('a bigger stone never goes on a smaller', () {
      // The smallest stone is on the middle staddle, the middle stone on the
      // first, the biggest on the last.
      final standing = Standing([1, 0, 2]);
      expect(standing.canMove(1, 0), isTrue);
      expect(standing.canMove(0, 1), isFalse);
      expect(standing.canMove(0, 2), isTrue);
      expect(standing.canMove(2, 1), isFalse);
    });

    test('packs and unpacks without loss', () {
      for (final on in [
        [0, 0, 0],
        [2, 1, 0],
        [1, 1, 2],
        [2, 2, 2],
      ]) {
        expect(Standing.unpack(Standing(on).key, 3).on, on);
      }
    });
  });

  group('the walk against the doubling', () {
    test('agree for every count of stones to nine', () {
      // The doubling is an argument: the biggest stone cannot move until the
      // rest are all on one other staddle, and they must all come back on
      // top. The walk knows nothing about arguments and looks at every
      // standing there is. They have to say the same number, and do.
      for (var stones = 1; stones <= 9; stones++) {
        final start = Standing(List.filled(stones, 0));
        expect(Moves(stones).from(start), Moves.doublingSays(stones),
            reason: '$stones stones');
      }
    });

    test('every distance is a real shortest way', () {
      // Every standing of the four stone yard: some neighbour is exactly one
      // nearer, none is more than one away.
      final moves = Moves(4);
      for (var key = 0; key < 81; key++) {
        final standing = Standing.unpack(key, 4);
        final far = moves.from(standing);
        if (far == 0) continue;
        var nearer = 0;
        for (var from = 0; from < 3; from++) {
          for (var to = 0; to < 3; to++) {
            if (!standing.canMove(from, to)) continue;
            final there = moves.from(standing.move(from, to));
            expect((there - far).abs(), lessThanOrEqualTo(1));
            if (there == far - 1) nearer++;
          }
        }
        expect(nearer, greaterThan(0));
      }
    });
  });

  group('every yard that ships', () {
    for (var number = 0; number < Yards.count; number++) {
      final yard = Yards.at(number);

      test('${yard.name} says what the walk and the doubling say', () {
        final start = Standing(List.filled(yard.stones, 0));
        expect(Moves(yard.stones).from(start), yard.fewest);
        expect(Moves.doublingSays(yard.stones), yard.fewest);
      });
    }

    test('each par is twice the last and one', () {
      for (var number = 1; number < Yards.count; number++) {
        expect(Yards.at(number).fewest, Yards.at(number - 1).fewest * 2 + 1);
      }
    });
  });

  group('a yard being worked', () {
    late Play play;

    setUp(() => play = Play.of(Yards.at(1), Moves(3)));

    test('starts stacked on the first staddle', () {
      expect(play.standing.on, [0, 0, 0]);
      expect(play.made, 0);
      expect(play.couldFinishIn, 7);
    });

    test('a stone is lifted, set down, or put back', () {
      play = play.touch(0);
      expect(play.lifted, 0);
      play = play.touch(0);
      expect(play.lifted, -1);
      expect(play.made, 0);

      play = play.touch(0).touch(2);
      expect(play.made, 1);
      expect(play.topOf(2), 0);
    });

    test('a bigger stone will not sit on a smaller', () {
      play = play.touch(0).touch(2);
      // The middle stone is now on top of the first staddle; it will not go
      // on the smallest.
      play = play.touch(0);
      expect(identical(play.touch(2), play), isTrue);
    });

    test('a bare staddle cannot be lifted from', () {
      expect(identical(play.touch(1), play), isTrue);
    });

    test('the wrong move costs, and the game knows at once', () {
      // The right first move on an odd count goes to the far staddle. The
      // wrong one does not put the distance up, it leaves it where it was,
      // because the single stone moves form a triangle; the move is a move
      // spent all the same.
      play = play.touch(0).touch(1);
      expect(play.left, 7);
      expect(play.couldFinishIn, 8);
    });

    test('again restacks the yard', () {
      play = play.touch(0).touch(2).again;
      expect(play.made, 0);
      expect(play.standing.on, [0, 0, 0]);
    });

    test('following the table works every yard at par', () {
      for (var number = 0; number < Yards.count; number++) {
        final yard = Yards.at(number);
        var walk = Play.of(yard, Moves(yard.stones));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 70) fail('${yard.name} never finished');
          final (from, to) = walk.next!;
          walk = walk.touch(from).touch(to);
        }
        expect(walk.made, yard.fewest, reason: yard.name);
        expect(walk.isFewest, isTrue, reason: yard.name);
      }
    });

    test('the biggest stone comes home exactly half way', () {
      // The doubling argument on screen: on the shortest way, the biggest
      // stone reaches the far staddle at move two to the n-1, with two to
      // the n-1 less one still to go.
      final yard = Yards.at(3);
      var walk = Play.of(yard, Moves(yard.stones));
      var movesWhenHome = -1;
      var guard = 0;
      while (!walk.isDone) {
        if (guard++ > 40) fail('it never finished');
        final (from, to) = walk.next!;
        walk = walk.touch(from).touch(to);
        if (movesWhenHome < 0 && walk.biggestHome) {
          movesWhenHome = walk.made;
        }
      }
      expect(movesWhenHome, 1 << (yard.stones - 1));
    });
  });
}
