import 'package:flutter_test/flutter_test.dart';
import 'package:rowsden/school/levels.dart';
import 'package:rowsden/school/play.dart';
import 'package:rowsden/school/rules.dart';

/// The law of the walk, held to.
void main() {
  group('the rules', () {
    test('there are 280 ways to walk nine out in rows of three', () {
      expect(Rules.days, hasLength(280));
      expect(Rules.days.first, [[0, 1, 2], [3, 4, 5], [6, 7, 8]]);
      for (final day in Rules.days) {
        expect(day.expand((r) => r).toSet(), hasLength(9));
      }
    });

    test('pairs of a row and a day', () {
      expect(Rules.pairsOfRow([0, 1, 2]), [Rules.pairKey(0, 1), Rules.pairKey(0, 2), Rules.pairKey(1, 2)]);
      expect(Rules.pairsOfDay(Levels.rows), hasLength(9));
      expect(Rules.pairKey(4, 2), Rules.pairKey(2, 4));
    });

    test('Kirkman\'s week meets every pair once', () {
      final week = Rules.affineWeek;
      expect(week[0], Levels.rows);
      expect(week[1], Levels.columns);
      expect(week[2], Levels.diagonals);
      expect(Rules.noPairTwice(week), isTrue);
      expect(Rules.pairsMet(week), hasLength(36));
      expect(Rules.daysNeeded, 4);
    });

    test('the completions count as told', () {
      expect(Rules.completions([Levels.rows], 1).$1, 36);
      expect(Rules.completions([Levels.rows, Levels.columns], 1).$1, 2);
      expect(Rules.completions([Levels.rows, Levels.columns, Levels.diagonals], 1).$1, 1);
      expect(Rules.completions([Levels.rows], 3).$1, 72);
      expect(Rules.completions([Levels.rows, Levels.columns, Levels.diagonals], 1).$2, [Rules.affineWeek[3]]);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        if (level.allPairs) continue;
        expect(Rules.completions(level.given, level.more).$1, level.ways, reason: level.name);
      }
      // Three days: no completion of two more days meets all 36 pairs.
      var landed = 0;
      final chosen = [Levels.rows];
      for (final d2 in Rules.days) {
        for (final d3 in Rules.days) {
          final days = [...chosen, d2, d3];
          if (Rules.noPairTwice(days) && Rules.pairsMet(days).length == 36) landed++;
        }
      }
      expect(landed, 0);
    });
  });

  group('the play', () {
    test('opens with nothing placed', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.placed, isEmpty, reason: level.name);
        expect(play.days, level.given);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap places, a girl placed today takes no tap, back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.placed, [0]);
      expect(play.currentRow, [0]);
      expect(play.tap(0), same(play));
      play = play.tap(3).tap(6);
      expect(play.currentRow, isEmpty);
      expect(play.today, [0, 3, 6]);
      expect(play.moves, 3);
      expect(play.back.placed, [0, 3]);
    });

    test('the weeks by hand', () {
      final second = Play.of(Levels.at(0)).tap(0).tap(3).tap(6).tap(1).tap(4).tap(7).tap(2).tap(5).tap(8);
      expect(second.isDone, isTrue);
      expect(second.pairsMet, hasLength(18));
      expect(second.tap(0), same(second));
      final repeat = Play.of(Levels.at(0)).tap(0).tap(1).tap(3).tap(2).tap(4).tap(6).tap(5).tap(7).tap(8);
      expect(repeat.full, isTrue);
      expect(repeat.repeats, greaterThan(0));
      expect(repeat.missed, isTrue);
      expect(repeat.gaveUp, isFalse);
      final third = Play.of(Levels.at(1)).tap(0).tap(4).tap(8).tap(1).tap(5).tap(6).tap(2).tap(3).tap(7);
      expect(third.isDone, isTrue);
      final fourth = Play.of(Levels.at(2)).tap(0).tap(5).tap(7).tap(1).tap(3).tap(8).tap(2).tap(4).tap(6);
      expect(fourth.isDone, isTrue);
      expect(fourth.pairsMet, hasLength(36));
    });

    test('the pointer lands every winnable week', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (what, g) = play.next!;
          play = what == 'out' ? play.back : play.tap(g);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer takes a strayed placing back', () {
      final play = Play.of(Levels.at(1)).tap(0).tap(1);
      expect(play.next, ('out', 1));
      expect(Play.of(Levels.at(1)).tap(0).next, ('in', 4));
    });

    test('the hopeless week cracks when three days are walked', () {
      var play = Play.of(Levels.at(4));
      for (final g in [0, 3, 6, 1, 4, 7, 2, 5, 8, 0, 4, 8, 1, 5, 6, 2, 3, 7]) {
        play = play.tap(g);
      }
      expect(play.full, isTrue);
      expect(play.repeats, 0);
      expect(play.pairsMet, hasLength(27));
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.tap(0), same(play));
    });

    test('the mark stands walked whole', () {
      final mark = Play.standing(Levels.at(3), const [0, 3, 6, 1, 4, 7, 2, 5, 8, 0, 4, 8, 1, 5, 6, 2, 3, 7, 0, 5, 7, 1, 3, 8, 2, 4, 6]);
      expect(mark.isDone, isTrue);
      expect(mark.pairsMet, hasLength(36));
    });
  });
}
