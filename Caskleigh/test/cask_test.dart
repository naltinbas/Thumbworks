import 'package:caskleigh/cask/frac.dart';
import 'package:caskleigh/cask/levels.dart';
import 'package:caskleigh/cask/play.dart';
import 'package:caskleigh/cask/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The cellar itself: the fractions, the twos, and the runs.
void main() {
  group('fractions', () {
    test('add and reduce exactly', () {
      expect((Frac.of(1, 2) + Frac.of(1, 3)).toString(), '5/6');
      expect((Frac.of(1, 6) + Frac.of(1, 3)).toString(), '1/2');
      expect((Frac.of(1, 2) + Frac.of(1, 2)).isWhole, isTrue);
      expect(Frac.of(3, 1).toString(), '3');
    });

    test('compare without turning into doubles', () {
      expect(Frac.of(1, 3) < Frac.of(1, 2), isTrue);
      expect(Frac.of(25, 12) > Frac.of(2), isTrue);
      expect(Frac.of(24, 12) > Frac.of(2), isFalse);
      expect(Frac.of(2, 4) == Frac.of(1, 2), isTrue);
    });
  });

  group('the run', () {
    test('comes to the same both ways', () {
      for (final (first, last) in [(3, 4), (2, 4), (1, 4), (1, 2), (1, 11)]) {
        expect(Rules.total(first, last), Rules.totalByCommon(first, last),
            reason: '$first to $last');
      }
    });

    test('the openings the game quotes', () {
      expect(Rules.total(3, 4).toString(), '7/12');
      expect(Rules.total(2, 4).toString(), '13/12');
      expect(Rules.total(1, 4).toString(), '25/12');
      expect(Rules.total(1, 2).toString(), '3/2');
      expect(Rules.total(1, 11).toString(), '83711/27720');
    });

    test('a long one is told to four places rather than in full', () {
      expect(Rules.tellTotal(Rules.total(3, 4)), '7/12');
      expect(Rules.tellTotal(Rules.total(1, 11)), '83711/27720');
      expect(Rules.tellTotal(Rules.total(1, 60)), 'about 4.6799');
    });

    test('needs two casks and stays inside the cellar', () {
      expect(Rules.validRun(3, 4), isTrue);
      expect(Rules.validRun(4, 4), isFalse);
      expect(Rules.validRun(0, 4), isFalse);
      expect(Rules.validRun(3, Rules.most + 1), isFalse);
    });
  });

  group('the twos', () {
    test('counted in a cask', () {
      expect([for (var k = 1; k <= 12; k++) Rules.twos(k)],
          [0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2]);
    });

    test('one cask of a run holds more than any other, always', () {
      for (final (first, last) in Rules.runs()) {
        expect(Rules.deepest(first, last).length, 1,
            reason: '$first to $last');
      }
    });

    test('and that is which cask', () {
      expect(Rules.deepest(3, 4), [4]);
      expect(Rules.deepest(1, 11), [8]);
      expect(Rules.deepest(1, 2), [2]);
      expect(Rules.mostTwos(1, 11), 3);
    });

    test('so no run comes to a whole barrel and every bottom is even', () {
      for (final (first, last) in Rules.runs()) {
        final total = Rules.total(first, last);
        expect(total.isWhole, isFalse, reason: '$first to $last');
        expect(total.d.isEven, isTrue, reason: '$first to $last');
      }
    });

    test('the cellar holds 1,770 runs', () {
      expect(Rules.runs().length, 1770);
      expect(Rules.howManyRuns, 1770);
    });
  });

  group('the asks', () {
    test('are landed by as many runs as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final (first, last) in Rules.runs()) {
          if (level.meets(first, last)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('name the cheapest run that lands them', () {
      for (final level in Levels.all) {
        final aim = level.aim;
        if (!level.winnable) {
          expect(aim, isNull, reason: level.name);
          continue;
        }
        expect(level.meets(aim!.$1, aim.$2), isTrue, reason: level.name);
        for (final (first, last) in Rules.runs()) {
          if (!level.meets(first, last)) continue;
          expect(Rules.taps(first, last), greaterThanOrEqualTo(level.fewest!),
              reason: '$first to $last against ${level.name}');
        }
      }
    });

    test('the fewest taps each one takes', () {
      expect([for (final level in Levels.all) level.fewest],
          [1, 2, 4, 9, null]);
    });
  });

  group('a go', () {
    test('opens on a 3rd to a 4th with no taps counted', () {
      final play = Play.of(Levels.at(0));
      expect((play.first, play.last), (3, 4));
      expect(play.moves, 0);
      expect(play.total.toString(), '7/12');
      expect(play.casks, 2);
      expect(play.isDone, isFalse);
    });

    test('steps an end at a time and counts the tap', () {
      final play = Play.of(Levels.at(0)).stepFirst(-1);
      expect((play.first, play.last), (2, 4));
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
    });

    test('refuses a step that would cross the run or leave the cellar', () {
      final play = Play.of(Levels.at(0));
      expect(identical(play.stepFirst(1), play), isTrue);
      expect(identical(play.stepFirst(0), play), isTrue);
      var deep = Play.standing(Levels.at(0), 58, Rules.most);
      expect(identical(deep.stepLast(1), deep), isTrue);
      deep = Play.standing(Levels.at(0), 1, 3);
      expect(identical(deep.stepFirst(-1), deep), isTrue);
    });

    test('back undoes the last tap', () {
      final play = Play.of(Levels.at(3)).stepFirst(-1).stepLast(1);
      expect((play.first, play.last), (2, 5));
      expect(play.moves, 2);
      expect((play.back.first, play.back.last), (2, 4));
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer walks to the aim and stops there', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final aim = play.next!;
          play = aim.$1 == 'first'
              ? play.stepFirst(aim.$2)
              : play.stepLast(aim.$2);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says which end and which way', () {
      expect(Play.pointed(('first', -1)),
          'Take the first cask one back up.');
      expect(Play.pointed(('last', 1)),
          'Take the last cask one further down the cellar.');
    });

    test('the hopeless ask admits it after four runs', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final by in [1, 1, 1, 1]) {
        play = play.stepLast(by);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(identical(play.stepLast(1), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 20; k++) {
        play = play.stepLast(1);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names the two who wrote it down', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('Kurschak'));
      expect(words, contains('1918'));
      expect(words, contains('Erdos'));
      expect(words, contains('The Whole Barrel'));
    });
  });
}
