import 'package:flutter_test/flutter_test.dart';
import 'package:winnowmere/sift/fewest.dart';
import 'package:winnowmere/sift/network.dart';
import 'package:winnowmere/sift/noughts.dart';
import 'package:winnowmere/sift/play.dart';
import 'package:winnowmere/sift/puzzles.dart';

void main() {
  group('a comparator', () {
    test('puts the smaller of two lines on the upper one', () {
      final sieve = Sieve(2, [Cross(0, 1)]);
      expect(sieve.through([2, 1]), [1, 2]);
      expect(sieve.through([1, 2]), [1, 2]);
    });

    test('and is the same comparator written either way round', () {
      expect(Cross(0, 3), Cross(3, 0));
      expect(Cross(0, 3).upper, 0);
      expect(Cross(3, 0).upper, 0);
    });

    test('and does the same thing to bits as it does to numbers', () {
      // The bit version is what all the checking uses, so it has to agree
      // with the plain one on every row there is.
      final sieve = Sieve(4, [Cross(0, 1), Cross(2, 3), Cross(0, 2), Cross(1, 3)]);
      for (var row = 0; row < 16; row++) {
        final asNumbers = sieve.through([
          for (var line = 0; line < 4; line++) (row >> line) & 1,
        ]);
        final asBits = sieve.throughBits(row);
        for (var line = 0; line < 4; line++) {
          expect((asBits >> line) & 1, asNumbers[line], reason: 'row $row');
        }
      }
    });
  });

  group('noughts and ones', () {
    test('are enough: a network that sorts them sorts anything', () {
      // The old result this game rests on. Here it is the other way round,
      // which is the checkable direction: take a network that sorts every row
      // of noughts and ones and throw real numbers at it.
      final sieve = Sieve(4, [
        Cross(0, 1),
        Cross(2, 3),
        Cross(0, 2),
        Cross(1, 3),
        Cross(1, 2),
      ]);
      expect(Noughts.sorts(sieve), isTrue);

      // Every ordering of four different numbers, and then some rows with
      // repeats in them.
      for (final row in _everyOrder([3, 1, 4, 2])) {
        expect(sieve.through(row), [1, 2, 3, 4], reason: '$row');
      }
      for (final row in _everyOrder([7, 7, 2, 9])) {
        expect(sieve.through(row), [2, 7, 7, 9], reason: '$row');
      }
    });

    test('and a network that misses one row is caught by that row', () {
      // Four lines, five comparators, one of them wrong.
      final sieve = Sieve(4, [
        Cross(0, 1),
        Cross(2, 3),
        Cross(0, 2),
        Cross(1, 3),
        Cross(0, 1),
      ]);
      final row = Noughts.fails(sieve);
      expect(row, isNotNull);

      final out = sieve.throughBits(row!);
      final words = Noughts.words(out, 4);
      expect(words.contains('10'), isTrue,
          reason: '$words is not out of order');
    });

    test('and counts how many rows come out right', () {
      expect(Noughts.right(Sieve(3, const [])), 4, reason: 'of eight');
      expect(Noughts.right(Sieve(3, [Cross(0, 1), Cross(0, 2), Cross(1, 2)])),
          8);
    });
  });

  group('the fewest there is', () {
    test('comes out at the numbers everybody else has', () {
      // 1, 3, 5, 9 and 12 for two lines up to six. Nothing here reads those
      // from anywhere: they come out of a walk over every network, with the
      // ones that leave the same rows behind counted once.
      const known = {2: 1, 3: 3, 4: 5, 5: 9, 6: 12};
      for (final one in known.entries) {
        final found = Fewest.forLines(one.key);
        expect(found, isNotNull, reason: '${one.key} lines');
        expect(found!.$1, one.value, reason: '${one.key} lines');
        expect(Noughts.sorts(found.$2), isTrue,
            reason: 'the network it gave back does not sort');
        expect(found.$2.crosses, hasLength(one.value));
      }
    });

    test('and no network of one fewer sorts at all', () {
      // Said the other way round, which is what "fewest" means: the walk
      // reaches nothing that sorts before it gets there.
      for (final lines in [3, 4, 5]) {
        final fewest = Fewest.forLines(lines)!.$1;
        expect(Fewest.forLines(lines, giveUpAfter: fewest - 1), isNull,
            reason: '$lines lines sorted in ${fewest - 1}');
      }
    });
  });

  group('every puzzle', () {
    test('can be finished in the number it promises', () {
      for (var i = 0; i < Siftings.count; i++) {
        final one = Siftings.at(i);
        final found = Fewest.fromHere(one.start, giveUpAfter: one.toFind + 1);
        expect(found, isNotNull, reason: one.name);
        expect(found!.$1, one.toFind, reason: one.name);
      }
    });

    test('and what it starts with is not already sorting', () {
      for (var i = 0; i < Siftings.count; i++) {
        final one = Siftings.at(i);
        expect(Noughts.sorts(one.start), isFalse, reason: one.name);
        expect(one.toFind, greaterThan(0), reason: one.name);
      }
    });

    test('and they get harder', () {
      var last = 0;
      for (var i = 0; i < Siftings.count; i++) {
        expect(Siftings.at(i).lines, greaterThanOrEqualTo(last));
        last = Siftings.at(i).lines;
      }
    });
  });

  group('building one', () {
    Play start([int which = 2]) => Play.of(Siftings.at(which));

    test('begins with what the puzzle gives it', () {
      final play = start(3);
      expect(play.count, Siftings.at(3).given.length);
      expect(play.given, Siftings.at(3).given.length);
      expect(play.isDone, isFalse);
      expect(play.right, lessThan(play.rows));
    });

    test('adds a comparator at the end', () {
      final play = start().add(0, 1);
      expect(play.count, 1);
      expect(play.sieve.crosses.last, Cross(0, 1));
      expect(play.changes, 1);
    });

    test('and refuses one that joins a line to itself', () {
      final play = start();
      expect(play.add(1, 1).count, 0);
      expect(play.add(0, 9).count, 0);
      expect(play.add(0, 1).changes, 1);
    });

    test('takes one out again, but never one the puzzle gave', () {
      var play = start(3).add(1, 2);
      expect(play.count, Siftings.at(3).given.length + 1);

      play = play.take(play.count - 1);
      expect(play.count, Siftings.at(3).given.length);

      // The given ones stay put.
      expect(play.take(0).count, play.count);
    });

    test('and is finished when nothing comes out unsorted', () {
      for (var which = 0; which < Siftings.count; which++) {
        final one = Siftings.at(which);
        var play = Play.of(one);
        final rest = Fewest.fromHere(one.start)!.$2;

        for (var i = play.count; i < rest.crosses.length; i++) {
          play = play.add(rest.crosses[i].upper, rest.crosses[i].lower);
        }
        expect(play.isDone, isTrue, reason: one.name);
        expect(play.isTight, isTrue, reason: one.name);
        expect(play.over, 0, reason: one.name);
        expect(play.right, play.rows, reason: one.name);
        expect(play.fails, isNull, reason: one.name);
      }
    });

    test('and says which row it is still getting wrong', () {
      final play = start().add(0, 1);
      final row = play.fails;
      expect(row, isNotNull);
      expect(play.wordsOf(row!), hasLength(play.lines));
      expect(play.outOf(row), isNot(play.wordsOf(row)),
          reason: 'the network did nothing to it at all');
    });
  });
}

/// Every ordering of a handful of numbers.
List<List<int>> _everyOrder(List<int> what) {
  if (what.length <= 1) return [List.of(what)];
  final found = <List<int>>[];
  for (var i = 0; i < what.length; i++) {
    final rest = List.of(what)..removeAt(i);
    for (final order in _everyOrder(rest)) {
      found.add([what[i], ...order]);
    }
  }
  return found;
}
