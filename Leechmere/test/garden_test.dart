import 'package:flutter_test/flutter_test.dart';
import 'package:leechmere/garden/level.dart';
import 'package:leechmere/garden/levels.dart';
import 'package:leechmere/garden/play.dart';
import 'package:leechmere/garden/rules.dart';

/// The garden's law, and the play that turns its dials, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the seasons', () {
    test('Ash cures nine in ten in spring and three in ten in autumn, Birch eight and two', () {
      expect(Rules.season(0, 0, 10), (9, 10));
      expect(Rules.season(0, 1, 10), (3, 10));
      expect(Rules.season(1, 0, 10), (8, 10));
      expect(Rules.season(1, 1, 10), (2, 10));
      expect(Rules.season(0, 0, 50), (45, 50));
      expect(Rules.season(1, 1, 40), (8, 40));
    });

    test('Ash is ahead of Birch in both seasons at every load', () {
      for (final a in Rules.loads) {
        for (final b in Rules.loads) {
          for (var s = 0; s < 2; s++) {
            expect(Rules.compare(Rules.season(0, s, a), Rules.season(1, s, b)), greaterThan(0));
          }
        }
      }
    });

    test('a year is the two seasons summed, cured and seen', () {
      expect(Rules.year(0, 30, 30), (36, 60));
      expect(Rules.year(1, 30, 30), (30, 60));
      expect(Rules.year(0, 10, 10), (12, 20));
      expect(Rules.year(1, 30, 10), (26, 40));
    });

    test('shares compare as exact fractions and read in a hundred', () {
      expect(Rules.compare((12, 20), (26, 40)), lessThan(0));
      expect(Rules.compare((36, 60), (36, 60)), 0);
      expect(Rules.compare((3, 4), (2, 3)), greaterThan(0));
      expect(Rules.inHundred((36, 60)), 60);
      expect(Rules.inHundred((26, 40)), 65);
      expect(Rules.inHundred((24, 60)), 40);
    });
  });

  group('the sweep', () {
    test('625 settings, and 154 of them reverse the year', () {
      expect(Rules.sweep((a1, a2, b1, b2) => true), (625, 625));
      expect(Rules.sweep(Levels.at(0).meets), (154, 625));
      expect(Rules.sweep(Levels.at(1).meets), (24, 625));
      expect(Rules.sweep(Levels.at(2).meets), (17, 625));
      expect(Rules.sweep(Levels.at(3).meets), (25, 625));
    });

    test('with the loads alike for both healers, no setting reverses', () {
      expect(Rules.sweepEqual(Levels.at(4).meets), (0, 25));
      expect(Rules.sweepEqual((a1, a2, b1, b2) => a1 == b1 && a2 == b2), (25, 25));
    });

    test('the first setting of each ask is the sweep\'s', () {
      expect(Rules.first(Levels.at(0).meets), (10, 10, 30, 10));
      expect(Rules.first(Levels.at(1).meets), (10, 10, 20, 10));
      expect(Rules.first(Levels.at(2).meets), (10, 20, 50, 10));
      expect(Rules.first(Levels.at(3).meets), (10, 50, 10, 10));
      expect(Rules.first(Levels.at(4).meets), isNull);
    });

    test('with equal loads Ash ends the year one in ten ahead exactly', () {
      final (tenths, all) = Rules.sweepEqual((a1, a2, b1, b2) {
        final ash = Rules.year(0, a1, a2), birch = Rules.year(1, b1, b2);
        return (ash.$1 * birch.$2 - birch.$1 * ash.$2) * 10 == ash.$2 * birch.$2;
      });
      expect((tenths, all), (25, 25));
      expect(Rules.year(0, 20, 50), (33, 70));
      expect(Rules.year(1, 20, 50), (26, 70));
    });

    test('every reversal has the loads uneven', () {
      Rules.sweep((a1, a2, b1, b2) {
        if (Levels.at(0).meets(a1, a2, b1, b2)) {
          expect(a1 == b1 && a2 == b2, isFalse);
        }
        return false;
      });
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Reversal with Equal Loads']);
      expect(Levels.at(4).equalLoads, isTrue);
      expect(Levels.at(4).kind, 'behind');
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the loads so Ash cures a smaller share of the year than Birch');
      expect(Levels.at(1).task, 'set the loads so Ash and Birch cure the same share of the year');
      expect(Levels.at(2).task, 'set the loads so Ash cures a fifth or more of the year less than Birch');
      expect(Levels.at(3).task, 'set the loads so Ash cures no more than two in five over the year');
      expect(Levels.at(4).task, 'set the loads, alike for both healers each season, so Ash cures a smaller share of the year than Birch');
    });

    test('an ask is met by the year it names', () {
      final Level reversal = Levels.at(0);
      expect(reversal.meets(30, 30, 30, 30), isFalse);
      expect(reversal.meets(30, 30, 30, 10), isTrue);
      expect(Levels.at(1).meets(30, 30, 40, 20), isTrue);
      expect(Levels.at(2).meets(10, 20, 50, 10), isTrue);
      expect(Levels.at(2).meets(30, 30, 30, 10), isFalse);
      expect(Levels.at(3).meets(10, 50, 30, 30), isTrue);
      expect(Levels.at(3).meets(20, 50, 30, 30), isFalse);
      expect(Levels.at(4).meets(30, 30, 30, 10), isFalse);
    });
  });

  group('the play', () {
    test('starts at thirty everywhere, Ash ahead', () {
      final play = Play.of(Levels.at(0));
      expect(play.loads, [30, 30, 30, 30]);
      expect(play.ashYear, (36, 60));
      expect(play.birchYear, (30, 60));
      expect(play.isDone, isFalse);
      expect(play.moves, 0);
    });

    test('a tap turns a dial up a ten and round from fifty to ten', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(3);
      expect(play.loads, [30, 30, 30, 40]);
      play = play.tap(3);
      expect(play.loads, [30, 30, 30, 50]);
      play = play.tap(3);
      expect(play.loads, [30, 30, 30, 10]);
      expect(play.moves, 3);
      expect(play.isDone, isTrue);
      expect(play.tap(0).loads, play.loads);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(2);
      expect(play.back.loads, [30, 30, 30, 30]);
      expect(play.back.back.loads, [30, 30, 30, 30]);
    });

    test('on the equal-loads ask both healers\' dials of a season move together', () {
      var play = Play.of(Levels.at(4));
      play = play.tap(1);
      expect(play.loads, [30, 40, 30, 40]);
      play = play.tap(2);
      expect(play.loads, [40, 40, 40, 40]);
      expect(play.isDone, isFalse);
    });

    test('the equal-loads ask gives up after twenty taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        expect(play.isOver, isFalse);
        play = play.tap(k % 4);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.moves, 20);
      expect(play.next, isNull);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(2));
      for (var k = 0; k < 24; k++) {
        play = play.tap(0);
      }
      expect(play.gaveUp, isFalse);
      expect(play.moves, 24);
    });

    test('the pointer names the first dial off the sweep\'s first setting', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, 0);
      play = play.tap(0).tap(0).tap(0);
      expect(play.loads, [10, 30, 30, 30]);
      expect(play.isDone, isFalse);
      expect(play.next, 1);
      play = play.tap(1).tap(1).tap(1).tap(1);
      expect(play.loads, [10, 20, 30, 30]);
      expect(play.next, 2);
    });

    test('three taps on Ash\'s spring dial reverse the year too', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(0).tap(0);
      expect(play.loads, [10, 30, 30, 30]);
      expect(play.ashYear, (18, 40));
      expect(play.birchYear, (30, 60));
      expect(play.isDone, isTrue);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var taps = 0;
        while (!play.isDone && taps < 20) {
          play = play.tap(play.next!);
          taps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
