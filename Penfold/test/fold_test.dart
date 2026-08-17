import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/fold/levels.dart';
import 'package:penfold/fold/play.dart';
import 'package:penfold/fold/rules.dart';

/// The folds, the whistles and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the folds', () {
    test('a whistle moves every sheep, and two together stay together', () {
      final fold = Rules.folds['the near fold']!;
      expect(Rules.whole, 15);
      expect(Rules.spread(15), 4);
      expect(Rules.after(fold, 15, 0), 10);
      expect(Rules.spread(Rules.after(fold, 15, 0)), 2);
      expect(Rules.after(fold, 1, 0), 2);
      expect(Rules.gathered(Rules.after(fold, 15, 0)), isFalse);
      // Left then right gathers this fold, in field 1.
      expect(Rules.afterCall(fold, 15, [0, 1]), 1);
      expect(Rules.gathered(Rules.afterCall(fold, 15, [0, 1])), isTrue);
      expect(Rules.standing(5), [0, 2]);
      expect(Rules.tellCall([0, 1, 0]), 'L R L');
      expect(Rules.tellField(0), '1');
    });

    test('the flock and the pairs agree on every fold of the asks', () {
      for (final fold in Rules.folds.values) {
        expect((Rules.fewest(fold) != null), Rules.pairsMeet(fold));
      }
      expect(Rules.fewest(Rules.folds['the near fold']!), 2);
      expect(Rules.fewest(Rules.folds['the low fold']!), 3);
      expect(Rules.fewest(Rules.folds['the far fold']!), 5);
      expect(Rules.fewest(Rules.folds['the long fold']!), 9);
      expect(Rules.fewest(Rules.folds['the turning fold']!), isNull);
      expect(Rules.pairsMeet(Rules.folds['the turning fold']!), isFalse);
    });

    test('a fold of two turning whistles never narrows', () {
      final fold = Rules.folds['the turning fold']!;
      expect(Rules.turnsOnly(fold, 0), isTrue);
      expect(Rules.turnsOnly(fold, 1), isTrue);
      for (final call in Rules.calls(10)) {
        expect(Rules.spread(Rules.afterCall(fold, Rules.whole, call)),
            Rules.fields);
      }
      expect(Rules.turnsOnly(Rules.folds['the near fold']!, 0), isFalse);
    });

    test('the calls that gather, counted', () {
      expect(Rules.gatherings(Rules.folds['the near fold']!, 2), 2);
      expect(Rules.gatherings(Rules.folds['the near fold']!, 1), 0);
      expect(Rules.gatherings(Rules.folds['the low fold']!, 3), 2);
      expect(Rules.gatherings(Rules.folds['the far fold']!, 5), 1);
      expect(Rules.gatherings(Rules.folds['the far fold']!, 4), 0);
      expect(Rules.gatherings(Rules.folds['the long fold']!, 9), 1);
      expect(Rules.gatherings(Rules.folds['the long fold']!, 8), 0);
      expect(Rules.calls(3).length, 8);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Turning Fold']);
      for (final level in Levels.all) {
        if (!level.winnable) continue;
        expect(Rules.gatherings(level.whistles, level.length), level.ways,
            reason: level.name);
        expect(level.fewest, level.length, reason: level.name);
      }
      expect(Levels.all.map((l) => l.length), [2, 3, 5, 9, 0]);
      expect(Levels.all.map((l) => l.ways), [2, 2, 1, 1, 0]);
      expect(Levels.all.map((l) => l.calls), [4, 8, 32, 512, 1]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task,
          'gather the flock in the near fold, which takes 2 whistles');
      expect(Levels.at(4).task, 'gather the flock in the turning fold');
    });
  });

  group('the play', () {
    test('opens with a sheep in every field', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.flock, Rules.whole);
        expect((play.moves, play.spread, play.isOver), (0, 4, false));
      }
    });

    test('a whistle moves the flock, and back undoes it', () {
      var play = Play.of(Levels.at(0));
      play = play.blow(0);
      expect(play.call, [0]);
      expect(play.spread, 2);
      expect(play.back.flock, Rules.whole);
      expect(play.blow(5), same(play));
      play = play.blow(1);
      expect(play.isDone, isTrue);
      expect(play.call, [0, 1]);
      expect(play.blow(0), same(play));
    });

    test('the pointer gathers every fold it can, in the fewest whistles', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final whistle = play.next;
          expect(whistle, isNotNull, reason: level.name);
          final was = play.away!;
          play = play.blow(whistle!);
          expect(play.away, was - 1, reason: level.name);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.length, reason: level.name);
      }
      expect(Play.pointed(0), 'Blow the left whistle.');
      expect(Play.pointed(1), 'Blow the right whistle.');
      expect(Play.of(Levels.at(4)).next, isNull);
      expect(Play.of(Levels.at(4)).away, isNull);
    });

    test('the long fold takes the one call of nine', () {
      var play = Play.of(Levels.at(3));
      for (final whistle in [1, 0, 0, 0, 1, 0, 0, 0, 1]) {
        play = play.blow(whistle);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 9);
      expect(Rules.tellCall(play.call), 'R L L L R L L L R');
    });

    test('the turning fold admits it after four standings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 4; k++) {
        play = play.blow(0);
        expect(play.spread, 4);
      }
      expect(play.seen.length, greaterThanOrEqualTo(1));
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.blow(k % 2);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.spread, 4);
      expect(wander.blow(0), same(wander));
    });

    test('the why tells Cerny and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Jan Cerny'));
      expect(words, contains('1964'));
      expect(words, contains('65,536'));
      expect(words, contains('This is ask 5, The Turning Fold.'));
      expect(words, contains('walked in full'));
    });
  });
}
