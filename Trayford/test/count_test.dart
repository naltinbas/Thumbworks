import 'package:flutter_test/flutter_test.dart';
import 'package:trayford/count/play.dart';
import 'package:trayford/count/rules.dart';
import 'package:trayford/count/trays.dart';

/// The law of the count, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final tray in Trays.all) {
        expect(Rules(tray.rows).counts(tray.asked), hasLength(tray.ways), reason: tray.name);
      }
    });

    test('the named counts', () {
      expect(Rules([3, 5]).counts([2, 4]), [14, 29]);
      expect(Rules([3, 5, 7]).counts([2, 3, 2]), [23]);
      expect(Rules([5, 7]).counts([3, 4]), [18]);
      expect(Rules([4, 6]).counts([1, 3]), [9, 21]);
      expect(Rules([4, 6]).counts([1, 2]), isEmpty);
      expect(Rules([4, 6], capacity: 1000).counts([1, 2]), isEmpty);
    });

    test('leftovers, spans and shared factors', () {
      expect(Rules([3, 5, 7]).leftovers(23), [2, 3, 2]);
      expect(Rules([3, 5, 7]).span, 105);
      expect(Rules([4, 6]).span, 12);
      expect(Rules([3, 5, 7]).coprime, isTrue);
      expect(Rules([4, 6]).coprime, isFalse);
      expect(Rules([4, 6]).meetable([1, 3]), isTrue);
      expect(Rules([4, 6]).meetable([1, 2]), isFalse);
    });

    test('Sun Tzu\'s construction lands on the sweep for every asking', () {
      for (final rows in [[3, 5], [5, 7], [3, 5, 7]]) {
        final rules = Rules(rows, capacity: Rules(rows).span - 1);
        var askings = 0;
        rules.askings((asked) {
          askings++;
          final counts = rules.counts(asked);
          expect(counts, hasLength(1), reason: '$rows $asked');
          expect(rules.byConstruction(asked), counts.first, reason: '$rows $asked');
        });
        expect(askings, rules.span);
      }
      expect(Rules([3, 5, 7]).byConstruction([2, 3, 2]), 23);
      expect(Rules([4, 6]).byConstruction([1, 3]), isNull);
    });

    test('fours and sixes meet only agreeing askings, twelve apart', () {
      final rules = Rules([4, 6]);
      var met = 0;
      rules.askings((asked) {
        final counts = rules.counts(asked);
        expect(counts.isNotEmpty, rules.meetable(asked), reason: '$asked');
        if (counts.isNotEmpty) {
          met++;
          for (var i = 1; i < counts.length; i++) {
            expect(counts[i] - counts[i - 1], 12);
          }
        }
      });
      expect(met, 12);
    });
  });

  group('the play', () {
    test('opens empty', () {
      for (final tray in Trays.all) {
        final play = Play.of(tray);
        expect(play.eggs, 0, reason: tray.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a fill sets the count, counted every one, and back undoes', () {
      var play = Play.of(Trays.at(0));
      play = play.fill(7);
      expect(play.eggs, 7);
      expect(play.moves, 1);
      expect(play.leftovers, [1, 2]);
      expect(play.met, [false, false]);
      play = play.fill(14);
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
      expect(play.back.eggs, 7);
      expect(play.fill(14), same(play));
    });

    test('a fill off the tray does nothing', () {
      final play = Play.of(Trays.at(0));
      expect(play.fill(-1), same(play));
      expect(play.fill(31), same(play));
      expect(play.fill(0), same(play));
    });

    test('the pointer fills the old count and the fives and sevens', () {
      for (final number in [1, 2]) {
        final play = Play.of(Trays.at(number));
        final aim = play.next!;
        expect(play.fill(aim).isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Trays.at(1)).next, 23);
      expect(Play.of(Trays.at(2)).next, 18);
    });

    test('the hopeless tray admits it at twelve fillings', () {
      var play = Play.of(Trays.at(4));
      for (var count = 1; count <= 12; count++) {
        play = play.fill(count);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.eggs, 12);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable tray never gives up', () {
      var play = Play.of(Trays.at(0));
      for (var count = 1; count <= 13; count++) {
        play = play.fill(count);
      }
      expect(play.moves, 13);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands met', () {
      final mark = Play.standing(Trays.at(1), 23);
      expect(mark.isDone, isTrue);
      expect(mark.leftovers, [2, 3, 2]);
    });
  });
}
