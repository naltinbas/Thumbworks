import 'package:flutter_test/flutter_test.dart';
import 'package:tuesleigh/family/frac.dart';
import 'package:tuesleigh/family/levels.dart';
import 'package:tuesleigh/family/play.dart';
import 'package:tuesleigh/family/rules.dart';

/// The families, the two chances, the asks and the play, checked at
/// the domain: nothing here touches a widget.
void main() {
  group('the families', () {
    test('a third with no tag, thirteen in twenty-seven with seven', () {
      expect(Rules.chanceByCounting(1), Frac.of(1, 3));
      expect(Rules.chanceByForm(1), Frac.of(1, 3));
      expect(Rules.chanceByCounting(7), Frac.of(13, 27));
      expect(Rules.chanceByForm(7), Frac.of(13, 27));
      expect(Rules.told(7), 27);
      expect(Rules.bothBoys(7), 13);
      expect(Rules.chanceToldWhich(7), Frac.of(1, 2));
      expect(Rules.chanceByForm(5), Frac.of(9, 19));
      expect(Rules.chanceByForm(30), Frac.of(59, 119));
      expect(Rules.tell(Frac.of(13, 27)), '13/27');
      expect(Rules.settings, 30);
    });

    test('counting and the form agree on every tag count, a half less one family in twice the told', () {
      for (var k = 1; k <= 30; k++) {
        expect(Rules.chanceByCounting(k), Rules.chanceByForm(k), reason: '$k');
        expect(Frac.of(1, 2) - Rules.chanceByForm(k), Frac.of(1, 2 * (4 * k - 1)), reason: '$k');
        expect(Rules.chanceToldWhich(k), Frac.of(1, 2), reason: '$k');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Half']);
      for (final level in Levels.all) {
        var n = 0;
        for (var k = 1; k <= 30; k++) {
          if (level.meets(k)) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, 1);
      expect(Levels.at(1).aim, 5);
      expect(Levels.at(2).aim, 7);
      expect(Levels.at(3).aim, 13);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial the tags so that the chance of two boys is 1 in 3');
      expect(Levels.at(3).task, 'dial the tags so that the chance of two boys is at least 49 in 100');
      expect(Levels.at(4).task, 'dial the tags so that the chance of two boys is a half');
    });

    test('an ask is met by the tag count alone', () {
      expect(Levels.at(0).meets(1), isTrue);
      expect(Levels.at(0).meets(2), isFalse);
      expect(Levels.at(1).meets(5), isTrue);
      expect(Levels.at(2).meets(7), isTrue);
      expect(Levels.at(2).meets(6), isFalse);
      expect(Levels.at(3).meets(13), isTrue);
      expect(Levels.at(3).meets(12), isFalse);
      expect(Levels.at(3).meets(30), isTrue);
      expect(Levels.at(4).meets(30), isFalse);
      expect(Levels.at(0).meets(0), isFalse);
      expect(Levels.at(0).meets(31), isFalse);
    });
  });

  group('the play', () {
    test('opens at two tags', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.tags, play.moves), (2, 0));
        expect(play.chance, Frac.of(3, 7));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('winds by one or ten, stopping at the ends', () {
      var play = Play.of(Levels.at(3)).wind(10);
      expect((play.tags, play.moves), (12, 1));
      expect(play.isDone, isFalse);
      play = play.wind(1);
      expect(play.tags, 13);
      expect(play.isDone, isTrue);
      final low = Play.of(Levels.at(1)).wind(-1);
      expect(low.tags, 1);
      expect(low.wind(-1), same(low));
      expect(low.wind(-10), same(low));
      var high = Play.of(Levels.at(1));
      for (var k = 0; k < 4; k++) {
        high = high.wind(10);
      }
      expect(high.tags, 30);
      expect(high.wind(1), same(high));
    });

    test('back undoes one wind', () {
      final play = Play.of(Levels.at(0)).wind(1).wind(1);
      expect(play.tags, 4);
      expect(play.back.tags, 3);
      expect(play.back.back.tags, 2);
    });

    test('the pointer winds towards the aim, ten while it can', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, 10);
      play = play.wind(10);
      expect(play.next, 1);
      expect(Play.pointed(10), 'Wind up by 10.');
      expect(Play.pointed(-1), 'Wind down by 1.');
      expect(Play.of(Levels.at(0)).next, -1);
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          play = play.wind(play.next!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the half admits it at the dial\'s end, or after fifteen taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 3; k++) {
        play = play.wind(10);
      }
      expect(play.tags, 30);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 15; k++) {
        wander = wander.wind(k.isEven ? 1 : -1);
      }
      expect(wander.tags, 3);
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells the Tuesday and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('born on a Tuesday'));
      expect(words, contains('all 30'));
      expect(words, contains('This is ask 5, The Half.'));
      expect(words, contains('counted out in full'));
    });
  });
}
