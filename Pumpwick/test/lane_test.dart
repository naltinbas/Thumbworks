import 'package:flutter_test/flutter_test.dart';
import 'package:pumpwick/lane/levels.dart';
import 'package:pumpwick/lane/play.dart';
import 'package:pumpwick/lane/rules.dart';

/// The lane, the houses and the walking, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the lane', () {
    test('the walking, and where it is least', () {
      const houses = [2, 3, 5, 8, 12];
      expect(Rules.walk(houses, 5), 15);
      expect(Rules.walk(houses, 6), 16);
      expect(Rules.leastWalk(houses), 15);
      expect(Rules.bestSpots(houses), [5]);
      expect(Rules.middleSpots(houses), [5]);
      expect(Rules.averageSpot(houses), 6);
      expect(Rules.tellHouses(houses), '2, 3, 5, 8, 12');
    });

    test('an even row leaves a run of best spots', () {
      const houses = [1, 3, 4, 8, 9, 11];
      expect(Rules.bestSpots(houses), [4, 5, 6, 7, 8]);
      expect(Rules.middleSpots(houses), [4, 5, 6, 7, 8]);
      expect(Rules.leastWalk(houses), 20);
      for (final spot in Rules.bestSpots(houses)) {
        expect(Rules.walk(houses, spot), 20);
      }
    });

    test('the middle and the sweep agree on every row up to five houses', () {
      var rows = 0;
      for (var count = 1; count <= 5; count++) {
        for (final houses in Rules.rows(count)) {
          rows++;
          expect(Rules.bestSpots(houses), Rules.middleSpots(houses),
              reason: Rules.tellHouses(houses));
        }
      }
      // 13 + 91 + 455 + 1,820 + 6,188 rows of one to five houses.
      expect(rows, 8567);
    });

    test('a step along changes the walking by the counts either side', () {
      for (var count = 1; count <= 4; count++) {
        for (final houses in Rules.rows(count)) {
          for (var spot = 0; spot < Rules.spots - 1; spot++) {
            expect(
                Rules.walk(houses, spot + 1) - Rules.walk(houses, spot),
                Rules.stepChange(houses, spot),
                reason: '${Rules.tellHouses(houses)} at $spot');
          }
        }
      }
      expect(Rules.stepChange([2, 3, 5, 8, 12], 4), -1);
      expect(Rules.stepChange([2, 3, 5, 8, 12], 5), 1);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['Beat the Middle']);
      for (final level in Levels.all) {
        var n = 0;
        for (var spot = 0; spot < Rules.spots; spot++) {
          if (level.meets(spot)) n++;
        }
        expect(n, level.ways, reason: level.name);
        expect(Rules.leastWalk(level.houses), level.walk, reason: level.name);
      }
      expect(Levels.all.map((l) => l.walk), [15, 20, 21, 11, 15]);
      expect(Levels.all.map((l) => l.ways), [1, 5, 1, 1, 0]);
      expect(Levels.all.map((l) => l.fewest), [5, 4, 9, 5, null]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'stand the pump where the walking comes to 15');
      expect(Levels.at(4).task,
          'stand the pump where the walking comes to less than 15');
    });
  });

  group('the play', () {
    test('opens with the pump at the near end', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.spot, 0);
        expect(play.moves, 0);
        expect(play.walk, Rules.walk(level.houses, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a step rolls the pump, and back rolls it home', () {
      var play = Play.of(Levels.at(0));
      play = play.step(1);
      expect(play.spot, 1);
      final home = play.step(-1);
      expect(home.spot, 0);
      expect(home.step(-1), same(home), reason: 'the lane ends');
      expect(play.step(2), same(play));
      expect(play.towards(5).spot, 2);
      expect(play.back.spot, 0);
      expect(play.moves, 1);
    });

    test('the pointer lands every ask it can, in the fewest steps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final way = play.next;
          expect(way, isNotNull, reason: level.name);
          play = play.step(way!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
      }
      expect(Play.pointed(1), 'Roll the pump one spot up the lane.');
      expect(Play.pointed(-1), 'Roll it one spot back.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('beat the middle admits it once the best spot has been stood on', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 5; k++) {
        play = play.step(1);
      }
      expect(play.spot, 5);
      expect(play.walk, 15);
      expect(play.seen, {5});
      expect(play.gaveUp, isTrue, reason: 'the least is the whole argument');
      expect(play.step(1), same(play));
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.step(k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, lessThanOrEqualTo(Play.gaveUpAt));
    });

    test('the why tells the middle and the average', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('the houses behind less the houses ahead'));
      expect(words, contains('The average is a different animal.'));
      expect(words, contains('This is ask 5, Beat the Middle.'));
      expect(words, contains('walked in full before the sham'));
    });
  });
}
