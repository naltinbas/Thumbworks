import 'package:flutter_test/flutter_test.dart';
import 'package:sashmoor/pane/play.dart';
import 'package:sashmoor/pane/rules.dart';
import 'package:sashmoor/pane/sashes.dart';

/// The law of the sash, held to.
void main() {
  group('the rules', () {
    test('four corners frame a window, both counts', () {
      final rules = Rules(3, 3);
      const panes = [(0, 0), (2, 0), (0, 2), (2, 2)];
      expect(rules.windowsByColumns(panes), 1);
      expect(rules.windowsByRows(panes), 1);
      expect(rules.windowFree(panes), isFalse);
      final (a, b, c, d) = rules.windows(panes).single;
      expect({a, b, c, d}, panes.toSet());
    });

    test('an ell of three frames nothing', () {
      final rules = Rules(3, 3);
      const panes = [(0, 0), (2, 0), (0, 2)];
      expect(rules.windowsByColumns(panes), 0);
      expect(rules.windowFree(panes), isTrue);
    });

    test('two columns sharing three rows frame three windows', () {
      final rules = Rules(4, 4);
      const panes = [(0, 0), (0, 1), (0, 2), (3, 0), (3, 1), (3, 2)];
      expect(rules.windowsByColumns(panes), 3);
      expect(rules.windowsByRows(panes), 3);
    });

    test('the two counts agree over the whole sweep', () {
      final small = Rules(3, 3);
      final big = Rules(4, 4);
      for (final count in [5, 6, 7]) {
        expect(small.countsAgree(count), isTrue, reason: '$count');
      }
      for (final count in [8, 9, 10]) {
        expect(big.countsAgree(count), isTrue, reason: '$count');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final sash in Sashes.all) {
        expect(
          Rules(sash.across, sash.down).waysTo(sash.count),
          sash.ways,
          reason: sash.name,
        );
      }
    });

    test('the row-pair arithmetic bars the tenth pane', () {
      final big = Rules(4, 4);
      expect(big.rowPairs, 6);
      expect(big.fewestSpend(10), 8);
      expect(big.waysTo(10), 0);
      final small = Rules(3, 3);
      expect(small.rowPairs, 3);
      expect(small.fewestSpend(7), 5);
      expect(small.waysTo(7), 0);
    });

    test('every window-free nine spends all six row-pairs', () {
      final big = Rules(4, 4);
      var slack = false;
      big.placings(9, (panes) {
        if (big.windowFree(panes) && big.rowPairsSpent(panes) != 6) {
          slack = true;
        }
      });
      expect(slack, isFalse);
    });
  });

  group('the play', () {
    test('taps set panes, tap again lifts them', () {
      var play = Play.of(Sashes.at(0)).tapAt((1, 1));
      expect(play.panes, [(1, 1)]);
      expect(play.moves, 1);
      play = play.tapAt((1, 1));
      expect(play.panes, isEmpty);
      expect(play.moves, 2);
    });

    test('a full sash refuses another pane', () {
      // Full but framing a window, so the sash is still open.
      var play = Play.of(Sashes.at(0));
      for (final light in const [(0, 0), (2, 0), (0, 2), (2, 2), (1, 1)]) {
        play = play.tapAt(light);
      }
      expect(play.allSet, isTrue);
      expect(play.isDone, isFalse);
      expect(play.tapAt((1, 0)), same(play));
      expect(play.tapAt((0, 0)).panes, hasLength(4));
    });

    test('the casement lands on any free five', () {
      var play = Play.of(Sashes.at(0));
      for (final light in const [(0, 0), (1, 0), (2, 0), (0, 1), (1, 2)]) {
        play = play.tapAt(light);
      }
      expect(play.windows, 0);
      expect(play.isDone, isTrue);
      expect(play.tapAt((2, 2)), same(play));
    });

    test('a window blocks the landing until a corner lifts', () {
      var play = Play.of(Sashes.at(0));
      for (final light in const [(0, 0), (2, 0), (0, 2), (2, 2), (1, 1)]) {
        play = play.tapAt(light);
      }
      expect(play.allSet, isTrue);
      expect(play.windows, 1);
      expect(play.isDone, isFalse);
      play = play.tapAt((2, 2)).tapAt((2, 1));
      expect(play.windows, 0);
      expect(play.isDone, isTrue);
    });

    test('the mark\'s placing lands the nine', () {
      final play = Play.standing(Sashes.at(3), const [
        (0, 0), (0, 1), (0, 2),
        (1, 0), (1, 3),
        (2, 1), (2, 3),
        (3, 2), (3, 3),
      ]);
      expect(play.windows, 0);
      expect(play.isDone, isTrue);
      expect(play.rules.rowPairsSpent(play.panes), 6);
    });

    test('back takes back one touch', () {
      final play = Play.of(Sashes.at(0)).tapAt((0, 0)).tapAt((1, 1));
      expect(play.back.panes, [(0, 0)]);
      expect(play.back.moves, 1);
      expect(Play.of(Sashes.at(0)).back.moves, 0);
    });

    test('show me walks to a glazing', () {
      var play = Play.of(Sashes.at(1));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        play = play.tapAt(aim!);
      }
      expect(play.isDone, isTrue);
    });

    test('show me lifts a windowed pane first', () {
      var play = Play.of(Sashes.at(0));
      for (final light in const [(0, 0), (2, 0), (0, 2), (2, 2)]) {
        play = play.tapAt(light);
      }
      expect(play.windows, 1);
      final aim = play.next;
      expect(aim, isNotNull);
      expect(play.panes, contains(aim));
    });

    test('the hopeless sash has nothing to point at', () {
      expect(Play.of(Sashes.at(4)).next, isNull);
    });

    test('the hopeless sash admits it after sixteen touches', () {
      var play = Play.of(Sashes.at(4));
      final all = play.rules.lights;
      for (final light in all.take(10)) {
        play = play.tapAt(light);
      }
      expect(play.windows, greaterThan(0));
      while (play.moves < Play.gaveUpAt) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(all.first);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable sash never gives up', () {
      var play = Play.of(Sashes.at(0));
      for (var touch = 0; touch < Play.gaveUpAt; touch++) {
        play = play.tapAt((0, 0));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
