import 'package:flutter_test/flutter_test.dart';
import 'package:stookwell/stook/levels.dart';
import 'package:stookwell/stook/play.dart';
import 'package:stookwell/stook/rules.dart';

/// The law of the stooks, held to.
void main() {
  group('the rules', () {
    test('the partitions of seven are fifteen, five apart and five odd', () {
      final seen = <String>[];
      Rules.partitions(7, (parts) => seen.add('$parts'));
      expect(seen, hasLength(15));
      expect(seen.first, '[7]');
      expect(seen.last, '[1, 1, 1, 1, 1, 1, 1]');
      expect(Rules.census(7), (15, 5, 5));
      expect(Rules.census(10), (42, 10, 10));
      expect(Rules.census(12), (77, 15, 15));
      expect(Rules.census(9), (30, 8, 8));
    });

    test('Euler\'s identity by walk and by product', () {
      final distinct = Rules.distinctByProduct(40);
      final odd = Rules.oddByProduct(40);
      for (var n = 1; n <= 20; n++) {
        final (_, d, o) = Rules.census(n);
        expect(d, o, reason: '$n');
        expect(distinct[n], d, reason: '$n');
        expect(odd[n], o, reason: '$n');
      }
      for (var n = 0; n <= 40; n++) {
        expect(distinct[n], odd[n], reason: '$n');
      }
    });

    test('Glaisher turns both ways and comes back', () {
      expect(Rules.merged([3, 3, 1]), [6, 1]);
      expect(Rules.merged([1, 1, 1, 1, 1, 1, 1]), [4, 2, 1]);
      expect(Rules.merged([5, 1, 1]), [5, 2]);
      expect(Rules.split([4, 3]), [3, 1, 1, 1, 1]);
      expect(Rules.split([6, 1]), [3, 3, 1]);
      for (var n = 1; n <= 15; n++) {
        Rules.partitions(n, (parts) {
          if (Rules.allOdd(parts)) {
            final m = Rules.merged(parts);
            expect(Rules.allDistinct(m), isTrue, reason: '$parts');
            expect(Rules.split(m), parts, reason: '$parts');
          }
          if (Rules.allDistinct(parts)) {
            final s = Rules.split(parts);
            expect(Rules.allOdd(s), isTrue, reason: '$parts');
            expect(Rules.merged(s), parts, reason: '$parts');
          }
        });
      }
    });

    test('k stooks apart need k(k + 1)/2 sheaves', () {
      expect(Rules.fewestFor(4), 10);
      expect(Rules.distinctWithParts(9, 4), 0);
      expect(Rules.distinctWithParts(10, 4), 1);
      expect(Rules.distinctWithParts(12, 4), 2);
      for (var k = 1; k <= 5; k++) {
        for (var n = 1; n < Rules.fewestFor(k); n++) {
          expect(Rules.distinctWithParts(n, k), 0, reason: '$n $k');
        }
      }
    });

    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        var all = 0, ways = 0;
        Rules.partitions(level.sheaves, (parts) {
          all++;
          if (level.meets(parts)) ways++;
        });
        expect(all, level.partitions, reason: level.name);
        expect(ways, level.ways, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with nothing stood', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.stooks, isEmpty, reason: level.name);
        expect(play.pool, level.sheaves);
        expect(play.isDone, isFalse);
      }
    });

    test('the pool begins a stook, a stook takes one more, and back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(Play.newStook);
      expect(play.stooks, [1]);
      expect(play.pool, 6);
      play = play.tap(0).tap(0);
      expect(play.stooks, [3]);
      expect(play.moves, 3);
      expect(play.tap(1), same(play));
      expect(play.back.stooks, [2]);
    });

    test('the harvests by hand', () {
      final apart = Play.of(Levels.at(0)).tap(-1).tap(0).tap(0).tap(0).tap(-1).tap(1).tap(-1);
      expect(apart.parts, [4, 2, 1]);
      expect(apart.isDone, isTrue);
      expect(apart.tap(-1), same(apart));
      final odd = Play.of(Levels.at(1)).tap(-1).tap(0).tap(0).tap(-1).tap(1).tap(1).tap(-1);
      expect(odd.parts, [3, 3, 1]);
      expect(odd.isDone, isTrue);
      final missed = Play.of(Levels.at(1)).tap(-1).tap(0).tap(0).tap(0).tap(-1).tap(1).tap(1);
      expect(missed.parts, [4, 3]);
      expect(missed.missed, isTrue);
      expect(missed.isOver, isTrue);
      expect(missed.gaveUp, isFalse);
    });

    test('the pointer lands every winnable harvest', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final (what, i) = play.next!;
          play = what == 'back' ? play.back : what == 'new' ? play.tap(Play.newStook) : play.tap(i);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.parts, Play.aimFor(Levels.at(number)), reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer takes a strayed standing back', () {
      final aim = Play.aimFor(Levels.at(0))!;
      expect(aim, [7]);
      final strayed = Play.of(Levels.at(0)).tap(-1).tap(-1);
      expect(strayed.next, ('back', 0));
      final onAim = Play.of(Levels.at(0)).tap(-1).tap(0);
      expect(onAim.next, ('add', 0));
    });

    test('the hopeless harvest cracks when every sheaf is stood', () {
      final play = Play.of(Levels.at(4)).tap(-1).tap(0).tap(0).tap(0).tap(-1).tap(1).tap(1).tap(-1).tap(-1);
      expect(play.parts, [4, 3, 1, 1]);
      expect(play.full, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(0), same(play));
    });

    test('the mark stands apart', () {
      final mark = Play.standing(Levels.at(0), const [4, 2, 1]);
      expect(mark.isDone, isTrue);
      expect(mark.moves, 7);
    });
  });
}
