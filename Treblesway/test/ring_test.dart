import 'package:flutter_test/flutter_test.dart';
import 'package:treblesway/ring/extent.dart';
import 'package:treblesway/ring/peals.dart';
import 'package:treblesway/ring/play.dart';
import 'package:treblesway/ring/tower.dart';

void main() {
  group('the tower', () {
    final tower = Towers.four('x');

    test('a change swaps the pairs it names and nothing else', () {
      expect(tower.changes[0].apply([0, 1, 2, 3]), [1, 0, 3, 2]);
      expect(tower.changes[2].apply([0, 1, 2, 3]), [0, 2, 1, 3]);
    });

    test('rounds is every bell in its own place, spoken 1234', () {
      expect(Tower.spoken(tower.rounds), '1234');
      expect(tower.rows, 24);
    });

    test('every change is its own undoing', () {
      for (final change in tower.changes) {
        expect(change.apply(change.apply([2, 0, 3, 1])), [2, 0, 3, 1]);
      }
    });
  });

  group('what each tower reaches', () {
    test('the split tower never crosses the middle', () {
      // The invariant the label rests on: with swaps only at the front pair,
      // the back pair and the cross, a bell in the front two places stays in
      // the front two places, so at most four rows can ever sound.
      final tower = Peals.at(4).tower;
      final seen = <int>{tower.keyOf(tower.rounds)};
      final waiting = [tower.rounds];
      while (waiting.isNotEmpty) {
        final row = waiting.removeLast();
        for (final change in tower.changes) {
          final next = change.apply(row);
          // The front pair is always some arrangement of bells 1 and 2.
          expect({next[0], next[1]}, {0, 1});
          if (seen.add(tower.keyOf(next))) waiting.add(next);
        }
      }
      expect(seen, hasLength(4));
    });

    test('the plain hunt reaches exactly eight rows', () {
      final tower = Peals.at(1).tower;
      final seen = <int>{tower.keyOf(tower.rounds)};
      final waiting = [tower.rounds];
      while (waiting.isNotEmpty) {
        final row = waiting.removeLast();
        for (final change in tower.changes) {
          final next = change.apply(row);
          if (seen.add(tower.keyOf(next))) waiting.add(next);
        }
      }
      expect(seen, hasLength(8));
    });
  });

  group('every peal that ships', () {
    for (var number = 0; number < Peals.count; number++) {
      final peal = Peals.at(number);

      test('${peal.name} has as many ways as the label says', () {
        expect(
          Extent(peal.tower, goalRows: peal.goalRows).countExtents(),
          peal.extents,
        );
      }, timeout: const Timeout(Duration(minutes: 2)));
    }

    test('the hopeless one is the only one with no way at all', () {
      expect(
        Peals.all.where((peal) => peal.extents == 0).map((peal) => peal.name),
        ['The Split Tower'],
      );
      expect(Peals.all.where((peal) => peal.hopeless), hasLength(1));
    });
  });

  group('ringing a peal', () {
    late Play play;

    setUp(() {
      final peal = Peals.at(0);
      play = Play.of(peal, Extent(peal.tower, goalRows: peal.goalRows));
    });

    test('opens at rounds with nothing rung', () {
      expect(Tower.spoken(play.at), '123');
      expect(play.made, 0);
      expect(play.rung, hasLength(1));
      expect(play.canStillRing, isTrue);
    });

    test('a pull brings a new row', () {
      play = play.pull(play.tower.changes[0]);
      expect(Tower.spoken(play.at), '213');
      expect(play.rung, hasLength(2));
    });

    test('a row that has sounded may not sound again', () {
      final change = play.tower.changes[0];
      play = play.pull(change);
      expect(play.mayRing(change), isFalse);
      expect(identical(play.pull(change), play), isTrue);
    });

    test('rounds may only strike home once everything has sounded', () {
      play = play.pull(play.tower.changes[0]);
      // The change that would undo it leads straight back to rounds, and
      // four rows have not sounded yet.
      expect(play.mayRing(play.tower.changes[0]), isFalse);
    });

    test('following the search brings every possible peal home', () {
      for (var number = 0; number < Peals.count; number++) {
        final peal = Peals.at(number);
        if (peal.hopeless) continue;
        var walk =
            Play.of(peal, Extent(peal.tower, goalRows: peal.goalRows));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 30) fail('${peal.name} never came round');
          walk = walk.pull(walk.next!);
        }
        expect(walk.made, peal.goalRows, reason: peal.name);
        expect(Tower.spoken(walk.at), Tower.spoken(peal.tower.rounds));
      }
    });

    test('the split tower is dead from the first blow', () {
      final peal = Peals.at(4);
      final walk =
          Play.of(peal, Extent(peal.tower, goalRows: peal.goalRows));
      expect(walk.canStillRing, isFalse);
      expect(walk.next, isNull);
    });

    test('a wrong turning is known the moment it is rung', () {
      // On the plain hunt the road is forced: from the second row there is
      // exactly one way on, and turning back is refused by the no-repeat
      // rule, so any legal pull keeps the peal alive. The full peal is the
      // one with wrong turnings to find; walk one deliberately.
      final peal = Peals.at(2);
      var walk = Play.of(peal, Extent(peal.tower, goalRows: peal.goalRows));
      var guard = 0;
      var sawDeath = false;
      // Ring greedily by first legal change; somewhere this strands rows.
      while (!walk.isDone && guard++ < 30) {
        final legal =
            walk.tower.changes.where(walk.mayRing).toList();
        if (legal.isEmpty) break;
        walk = walk.pull(legal.first);
        if (!walk.canStillRing) {
          sawDeath = true;
          break;
        }
      }
      expect(sawDeath || walk.isDone, isTrue);
    });
  });
}
