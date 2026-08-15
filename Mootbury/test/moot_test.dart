import 'package:flutter_test/flutter_test.dart';
import 'package:mootbury/moot/levels.dart';
import 'package:mootbury/moot/play.dart';
import 'package:mootbury/moot/rules.dart';

/// The two rules, the paradox and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the sharing', () {
    test('largest remainders: quotas, floors and the seats left over', () {
      expect(Rules.quotas([6, 6, 2], 10), [(60, 14), (60, 14), (20, 14)]);
      expect(Rules.quotaWords((60, 14)), '4 2/7');
      expect(Rules.quotaWords((20, 14)), '1 3/7');
      expect(Rules.quotaWords((7, 9)), '7/9');
      expect(Rules.hamilton([6, 6, 2], 10), [4, 4, 2]);
      expect(Rules.hamilton([6, 6, 2], 11), [5, 5, 1]);
      expect(Rules.hamilton([6, 6, 2], 7), [3, 3, 1]);
      expect(Rules.hamilton([5, 3, 1], 7), [4, 2, 1]);
      expect(Rules.hamilton([12, 7, 4, 2], 19), [9, 5, 3, 2]);
      expect(Rules.hamilton([12, 7, 4, 2], 20), [10, 6, 3, 1]);
    });

    test('dealing a seat at a time, and the divisor reading agrees', () {
      expect(Rules.jeffersonDealt([5, 3, 1], 7), [5, 2, 0]);
      expect(Rules.jeffersonDealt([6, 6, 2], 10), [5, 4, 1]);
      expect(Rules.jeffersonDealt([6, 6, 2], 7), [3, 3, 1]);
      for (final pops in [[6, 6, 2], [5, 3, 1], [12, 7, 4, 2], [9, 5, 3, 1]]) {
        for (var s = 1; s <= 30; s++) {
          expect(Rules.jeffersonByDivisor(pops, s), Rules.jeffersonDealt(pops, s), reason: '$pops at $s');
          expect(Rules.jeffersonFalls(pops, s), isFalse, reason: '$pops at $s');
        }
      }
    });

    test('the paradox, the broken quota and the whole shares', () {
      expect(Rules.alabama([6, 6, 2], 10), isTrue);
      expect(Rules.alabama([6, 6, 2], 9), isFalse);
      expect(Rules.loser([6, 6, 2], 10), 2);
      expect(Rules.loser([6, 6, 2], 9), isNull);
      expect(Rules.overQuota([5, 3, 1], 7), isTrue);
      expect(Rules.overQuota([5, 3, 1], 8), isFalse);
      expect(Rules.wholeQuotas([6, 6, 2], 7), isTrue);
      expect(Rules.wholeQuotas([6, 6, 2], 8), isFalse);
    });

    test('the sweep\'s counts', () {
      expect(Rules.sweep((s) => true), (29, 29));
      expect(Rules.sweep(Levels.at(0).meets), (4, 29));
      expect(Rules.sweep(Levels.at(1).meets), (1, 29));
      expect(Rules.sweep(Levels.at(2).meets), (3, 29));
      expect(Rules.sweep(Levels.at(3).meets), (4, 29));
      expect(Rules.sweep(Levels.at(4).meets), (0, 29));
      expect(Rules.first(Levels.at(0).meets), 3);
      expect(Rules.first(Levels.at(1).meets), 19);
      expect(Rules.first(Levels.at(2).meets), 7);
      expect(Rules.first(Levels.at(3).meets), 7);
      expect(Rules.first(Levels.at(4).meets), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Jefferson Paradox']);
      for (final level in Levels.all) {
        expect(Play.of(level).isDone, isFalse, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'size the moot of hamlets of 6, 6 and 2 hundred so that one more seat by largest remainders costs a hamlet a seat');
      expect(Levels.at(2).task, 'size the moot of hamlets of 5, 3 and 1 hundred so that dealing gives a hamlet more than its quota rounded up');
      expect(Levels.at(4).task, 'size the moot of hamlets of 6, 6 and 2 hundred so that one more seat by dealing costs a hamlet a seat');
    });
  });

  group('the play', () {
    test('opens at five seats', () {
      final play = Play.of(Levels.at(0));
      expect(play.seats, 5);
      expect(play.hamilton, [2, 2, 1]);
      expect(play.loser, isNull);
    });

    test('sizes by ones and fives within two and thirty', () {
      var play = Play.of(Levels.at(0));
      play = play.size(5);
      expect(play.seats, 10);
      expect(play.isDone, isTrue);
      play = Play.of(Levels.at(1)).size(-5);
      expect(play.seats, 2);
      expect(play.moves, 1);
      play = play.size(-1);
      expect(play.seats, 2);
      expect(play.moves, 1);
    });

    test('back undoes one sizing', () {
      final play = Play.of(Levels.at(0)).size(1);
      expect(play.back.seats, 5);
    });

    test('the jefferson paradox gives up after twenty-four sizings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        play = play.size(k.isEven ? 1 : -1);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer steps toward the first moot that lands', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, 5);
      play = play.size(5).size(5);
      expect(play.seats, 15);
      expect(play.next, 1);
      play = play.size(1).size(1).size(1).size(1);
      expect(play.seats, 19);
      expect(play.isDone, isTrue);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var presses = 0;
        while (!play.isDone && presses < 40) {
          play = play.size(play.next!);
          presses++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
