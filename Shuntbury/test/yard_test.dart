import 'package:flutter_test/flutter_test.dart';
import 'package:shuntbury/yard/levels.dart';
import 'package:shuntbury/yard/play.dart';
import 'package:shuntbury/yard/rules.dart';

/// The yard, the walk, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the yard', () {
    test('keys, berths beside, and a shunt', () {
      expect(Rules.unkey(Rules.key(Rules.home)), Rules.home);
      expect(Rules.beside(4), [1, 7, 3, 5]);
      expect(Rules.beside(0), [3, 1]);
      expect(Rules.beside(8), [5, 7]);
      expect(Rules.shunt(Rules.home, 5), [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      expect(Rules.shunt(Rules.home, 7), [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(Rules.shunt(Rules.home, 4), isNull);
      expect(Rules.told(Rules.home), '1 2 3 / 4 5 6 / 7 8 _');
    });

    test('pairs out of order', () {
      expect(Rules.inversions(Rules.home), 0);
      expect(Rules.inversions([1, 2, 3, 4, 5, 6, 8, 7, 0]), 1);
      expect(Rules.inversions([8, 6, 7, 2, 5, 4, 3, 0, 1]), 24);
      expect(Rules.evenByCount([1, 2, 0, 4, 5, 3, 7, 8, 6]), isTrue);
    });

    test('the walk from home', () {
      expect(Rules.distances.length, 181440);
      expect(Rules.fewest(Rules.home), 0);
      expect(Rules.fewest([1, 2, 0, 4, 5, 3, 7, 8, 6]), 2);
      expect(Rules.fewest([8, 6, 7, 2, 5, 4, 3, 0, 1]), 31);
      expect(Rules.fewest([1, 2, 3, 4, 5, 6, 8, 7, 0]), isNull);
      expect(Rules.reachable([1, 2, 3, 4, 5, 6, 8, 7, 0]), isFalse);
      expect(Rules.next(Rules.home), isNull);
      expect(Rules.next([1, 2, 3, 4, 5, 6, 7, 0, 8]), 8);
      expect(Rules.next([1, 2, 3, 4, 5, 6, 8, 7, 0]), isNull);
      // A sample of the parity across arrangements.
      var n = 0;
      for (final yard in Rules.allYards) {
        if (n++ % 997 != 0) continue;
        expect(Rules.reachable(yard), Rules.evenByCount(yard), reason: Rules.told(yard));
      }
      expect(n, 362880);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Swapped Pair']);
      for (final level in Levels.all) {
        expect(Rules.fewest(level.start), level.fewest, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'shunt the wagons home from 1 2 _ / 4 5 3 / 7 8 6, the fewest being two');
      expect(Levels.at(3).task, 'shunt the wagons home from 8 6 7 / 2 5 4 / 3 _ 1, the fewest being thirty-one');
      expect(Levels.at(4).task, 'shunt the wagons home from 1 2 3 / 4 5 6 / 8 7 _');
    });

    test('an ask is met at home', () {
      expect(Levels.at(0).meets(Rules.home), isTrue);
      expect(Levels.at(0).meets(Levels.at(0).start), isFalse);
      expect(Levels.at(4).meets(Rules.home), isTrue);
    });
  });

  group('the play', () {
    test('opens at the start', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.yard, level.start);
        expect(play.moves, 0);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap shunts a wagon beside the gap, and nothing else', () {
      var play = Play.of(Levels.at(0));
      expect(play.gap, 2);
      expect(play.tap(0), same(play));
      expect(play.tap(4), same(play));
      play = play.tap(5);
      expect(play.yard, [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      expect(play.moves, 1);
      expect(play.fewest, 1);
      play = play.tap(8);
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
      expect(play.tap(7), same(play));
    });

    test('back undoes one shunt', () {
      final play = Play.of(Levels.at(0)).tap(5);
      expect(play.back.yard, Levels.at(0).start);
      expect(play.back.back.moves, 0);
    });

    test('the pointer walks the shortest way home', () {
      var play = Play.of(Levels.at(1));
      var steps = 0;
      while (!play.isDone && steps < 40) {
        play = play.tap(play.next!);
        steps++;
      }
      expect((play.isDone, play.moves), (true, 7));
      for (final level in Levels.all.where((l) => l.winnable)) {
        var p = Play.of(level);
        while (!p.isDone) {
          p = p.tap(p.next!);
        }
        expect(p.moves, level.fewest, reason: level.name);
      }
      expect(Play.of(Levels.at(4)).next, isNull);
      expect(Play.pointed(8), 'Shunt the ringed wagon, the one at the bottom right.');
      expect(Play.pointed(3), 'Shunt the ringed wagon, berth 4.');
    });

    test('the swapped pair admits it after forty shunts', () {
      var play = Play.of(Levels.at(4));
      expect(play.fewest, isNull);
      for (var k = 0; k < 40; k++) {
        play = play.tap(k.isEven ? 7 : 8);
      }
      expect((play.moves, play.gaveUp), (40, true));
      expect(play.next, isNull);
    });

    test('the why tells the parity and the walk', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('So the count stays even or stays odd'));
      expect(words, contains('This is ask 5, The Swapped Pair.'));
      expect(words, contains('181,440 of the 362,880 arrangements'));
    });
  });
}
