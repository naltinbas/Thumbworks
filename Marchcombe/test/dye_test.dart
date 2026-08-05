import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:marchcombe/dye/fewest.dart';
import 'package:marchcombe/dye/land.dart';
import 'package:marchcombe/dye/lands.dart';
import 'package:marchcombe/dye/play.dart';

/// A grid split into contiguous fields at random, the same way the tool that
/// found the shipped maps does it.
Land _madeUp(Random random, {int wide = 5, int tall = 5, int many = 6}) {
  final grid = List.generate(tall, (_) => List.filled(wide, -1));
  final frontier = List.generate(many, (_) => <(int, int)>[]);

  final seeds = <(int, int)>{};
  while (seeds.length < many) {
    seeds.add((random.nextInt(wide), random.nextInt(tall)));
  }
  var field = 0;
  for (final (column, row) in seeds) {
    grid[row][column] = field;
    frontier[field++].add((column, row));
  }

  var left = wide * tall - many;
  var guard = 0;
  while (left > 0) {
    if (guard++ > 10000) break;
    for (var one = 0; one < many && left > 0; one++) {
      if (frontier[one].isEmpty) continue;
      final take = random.nextInt(frontier[one].length);
      final (column, row) = frontier[one][take];
      final open = <(int, int)>[];
      for (final (across, down) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        final there = (column + across, row + down);
        if (there.$1 < 0 || there.$2 < 0) continue;
        if (there.$1 >= wide || there.$2 >= tall) continue;
        if (grid[there.$2][there.$1] < 0) open.add(there);
      }
      if (open.isEmpty) {
        frontier[one].removeAt(take);
        continue;
      }
      final (nextColumn, nextRow) = open[random.nextInt(open.length)];
      grid[nextRow][nextColumn] = one;
      frontier[one].add((nextColumn, nextRow));
      left--;
    }
  }

  const letters = 'ABCDEFGHIJKLMNOP';
  return Land(
    name: 'made up',
    rows: [for (final row in grid) row.map((f) => letters[f]).join()],
  );
}

/// Every way of painting a map in this many dyes, tried one after another, to
/// see whether any of them is a proper one.
bool _anyPaintingIn(Land land, int many) {
  final dyes = List.filled(land.count, 0);
  final all = pow(many, land.count).toInt();
  for (var go = 0; go < all; go++) {
    var left = go;
    for (var field = 0; field < land.count; field++) {
      dyes[field] = left % many;
      left ~/= many;
    }
    if (land.isProper(dyes)) return true;
  }
  return false;
}

void main() {
  group('the map', () {
    final land = Estates.at(1).land;

    test('reads the fields off the grid in the order they appear', () {
      expect(land.count, 5);
      expect(land.fields.first.name, 'Great Ley');
      expect(land.fields.last.name, 'Barrow Piece');
    });

    test('two fields share a hedge when their squares are side by side', () {
      expect(land.touches(0, 1), isTrue);
      expect(land.touches(0, 2), isTrue);
      expect(land.touches(0, 3), isFalse);
      expect(land.touches(0, 4), isFalse);
    });

    test('a square outside the estate belongs to nobody', () {
      final gappy = Land(name: 'gappy', rows: const ['A.B', 'A.B']);
      expect(gappy.at(1, 0), -1);
      expect(gappy.touches(0, 1), isFalse);
    });

    test('knows a proper painting from an improper one', () {
      expect(land.isProper([0, 1, 2, 0, 1]), isTrue);
      expect(land.isProper([0, 0, 2, 0, 1]), isFalse);
      expect(land.isProper([0, 1, 2, 0, -1]), isFalse);
    });
  });

  group('the fewest dyes', () {
    test('a row of fields is two', () {
      final row = Land(name: 'row', rows: const ['AABBCCDD']);
      expect(Dyes.fewestFor(row).fewest, 2);
    });

    test('three fields that all meet is three', () {
      final three = Land(name: 'three', rows: const ['AAB', 'CCC']);
      final painting = Dyes.fewestFor(three);
      expect(painting.fewest, 3);
      expect(painting.ring, hasLength(3));
    });

    test('the painting it gives back is a proper one', () {
      for (var number = 0; number < Estates.count; number++) {
        final land = Estates.at(number).land;
        expect(land.isProper(Dyes.fewestFor(land).dyes), isTrue,
            reason: land.name);
      }
    });

    test('the ring is a set of fields that all share a hedge', () {
      for (var number = 0; number < Estates.count; number++) {
        final land = Estates.at(number).land;
        final ring = Dyes.fewestFor(land).ring;
        for (final one in ring) {
          for (final other in ring) {
            if (one == other) continue;
            expect(land.touches(one, other), isTrue, reason: land.name);
          }
        }
      }
    });
  });

  group('the two ways of working it out', () {
    test('agree on three hundred maps made up at random', () {
      final random = Random(11235);
      for (var go = 0; go < 300; go++) {
        final land = _madeUp(
          random,
          wide: 4 + random.nextInt(3),
          tall: 4 + random.nextInt(3),
          many: 4 + random.nextInt(5),
        );
        final painting = Dyes.fewestFor(land).fewest;
        final covering = Dyes.byCovering(land);
        expect(painting, covering,
            reason: 'painting says $painting and covering says $covering on '
                '${land.rows}');
      }
    });

    test('and one fewer is not enough, tried every way there is', () {
      // The slowest and least clever check there is: every painting in one
      // dye fewer than the answer, and none of them proper.
      final random = Random(31337);
      for (var go = 0; go < 60; go++) {
        final land = _madeUp(random, wide: 4, tall: 4, many: 4);
        final fewest = Dyes.fewestFor(land).fewest;
        expect(_anyPaintingIn(land, fewest), isTrue, reason: '${land.rows}');
        if (fewest > 1) {
          expect(_anyPaintingIn(land, fewest - 1), isFalse,
              reason: '${land.rows}');
        }
      }
    });

    test('and the ring never claims more than the answer', () {
      final random = Random(9001);
      for (var go = 0; go < 300; go++) {
        final land = _madeUp(random, many: 4 + random.nextInt(5));
        final painting = Dyes.fewestFor(land);
        expect(painting.ring.length, lessThanOrEqualTo(painting.fewest),
            reason: '${land.rows}');
      }
    });
  });

  group('counting the paintings', () {
    test('a row of two fields in three dyes is six', () {
      expect(Dyes.ways(Land(name: 'two', rows: const ['AB']), 3), 6);
    });

    test('and none at all in one', () {
      expect(Dyes.ways(Land(name: 'two', rows: const ['AB']), 1), 0);
    });

    test('the middle maps have one painting, the pots aside', () {
      // Six paintings in three dyes is the same painting with the pots
      // swapped round all six ways, so there is only the one.
      for (final number in const [2, 3, 4]) {
        final land = Estates.at(number).land;
        expect(Dyes.ways(land, 3), 6, reason: land.name);
      }
    });
  });

  group('every estate that ships', () {
    for (var number = 0; number < Estates.count; number++) {
      final estate = Estates.at(number);
      final land = estate.land;

      test('${land.name} says the number both ways of working it out say', () {
        expect(Dyes.fewestFor(land).fewest, estate.fewest);
        expect(Dyes.byCovering(land), estate.fewest);
      });

      test('${land.name} carries a ring that proves it', () {
        final painting = Dyes.fewestFor(land);
        expect(painting.ring, hasLength(estate.fewest));
      });

      test('${land.name} has fields that hang together and are all named', () {
        expect(land.count, land.letters.length);
        expect(land.fields.map((field) => field.name).toSet(),
            hasLength(land.count));
        for (final field in land.fields) {
          expect(field.squares.length, greaterThan(1));
          expect(_isOnePiece(land, field.squares), isTrue,
              reason: '${field.name} is in two pieces');
        }
      });
    }

    test('and past the first two, painting them in order is not enough', () {
      for (var number = 2; number < Estates.count; number++) {
        final estate = Estates.at(number);
        final inOrder = Dyes.byOrder(estate.land).reduce(max) + 1;
        expect(inOrder, greaterThan(estate.fewest), reason: estate.name);
      }
    });
  });

  group('painting one', () {
    late Play play;

    setUp(() => play = Play.of(Estates.at(1).land, Estates.answerFor(1)));

    test('starts with nothing painted', () {
      expect(play.done, 0);
      expect(play.isFull, isFalse);
      expect(play.isDone, isFalse);
      expect(play.most, 4);
    });

    test('painting a field puts a dye on it', () {
      play = play.paint(0, 1);
      expect(play.dyeOf(0), 1);
      expect(play.done, 1);
    });

    test('painting it the same dye again rubs it out', () {
      play = play.paint(0, 1).paint(0, 1);
      expect(play.dyeOf(0), -1);
      expect(play.done, 0);
    });

    test('two fields sharing a hedge in the same dye is a clash', () {
      play = play.paint(0, 0).paint(2, 0);
      expect(play.clashes, hasLength(1));
      expect(play.isDone, isFalse);
    });

    test('it is finished when every field is painted and nothing clashes', () {
      for (var field = 0; field < play.land.count; field++) {
        play = play.paint(field, play.painting.dyes[field]);
      }
      expect(play.isDone, isTrue);
      expect(play.isFewest, isTrue);
      expect(play.used, hasLength(play.fewest));
    });

    test('and finished on the spare dye is finished, but not the fewest', () {
      final land = play.land;
      for (var field = 0; field < land.count; field++) {
        play = play.paint(field, play.painting.dyes[field]);
      }
      // Repaint one field in the dye nobody needs. Its neighbours cannot be
      // in that dye, since nothing else uses it.
      play = play.paint(0, play.fewest);
      expect(play.isDone, isTrue);
      expect(play.isFewest, isFalse);
    });

    test('it knows when the fewest has been thrown away', () {
      final three = Land(name: 'three', rows: const ['AAB', 'CCC']);
      var walk = Play.of(three, Dyes.fewestFor(three));
      expect(walk.canStillDoIt, isTrue);
      walk = walk.paint(0, 3);
      expect(walk.canStillDoIt, isFalse);
    });

    test('and show me names a field and a dye that keeps it', () {
      for (var number = 0; number < Estates.count; number++) {
        var walk = Play.of(Estates.at(number).land, Estates.answerFor(number));
        var guard = 0;
        while (!walk.isFull) {
          if (guard++ > 40) fail('it never finished');
          final next = walk.next;
          expect(next, isNotNull, reason: Estates.at(number).name);
          walk = walk.paint(next!.$1, next.$2);
        }
        expect(walk.isDone, isTrue, reason: Estates.at(number).name);
        expect(walk.isFewest, isTrue, reason: Estates.at(number).name);
      }
    });
  });
}

/// Whether the squares of a field are all reachable from each other.
bool _isOnePiece(Land land, List<(int, int)> squares) {
  final left = squares.toSet();
  final waiting = <(int, int)>[squares.first];
  left.remove(squares.first);

  while (waiting.isNotEmpty) {
    final (column, row) = waiting.removeLast();
    for (final (across, down) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
      final there = (column + across, row + down);
      if (left.remove(there)) waiting.add(there);
    }
  }
  return left.isEmpty;
}
