import 'package:flutter_test/flutter_test.dart';
import 'package:fevershaw/village/levels.dart';
import 'package:fevershaw/village/play.dart';
import 'package:fevershaw/village/rules.dart';

/// The counting, the chances and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the village', () {
    test('counted whole in ten million', () {
      expect(Rules.counted(100, (99, 100), (1, 100)), (100000, 9900000, 99000, 99000));
      expect(Rules.counted(1000, (99, 100), (1, 100)), (10000, 9990000, 9900, 99900));
      expect(Rules.counted(2, (9, 10), (1, 10)), (5000000, 5000000, 4500000, 500000));
      expect(Rules.whole(1000, (999, 1000), (1, 1000)), isTrue);
    });

    test('the share by counting and by chances, the same', () {
      expect(Rules.byCounting(100, (99, 100), (1, 100)), (1, 2));
      expect(Rules.byChances(100, (99, 100), (1, 100)), (1, 2));
      expect(Rules.byChances(1000, (99, 100), (1, 100)), (11, 122));
      expect(Rules.byCounting(1000, (99, 100), (1, 100)), (11, 122));
      expect(Rules.byChances(2, (9, 10), (1, 10)), (9, 10));
      expect(Rules.byChances(100, (1, 1), (0, 1)), (1, 1));
      expect(Rules.byChances(100, (9, 10), (0, 1)), (1, 1));
      for (final p in Rules.prevalences) {
        for (final c in Rules.catches) {
          for (final a in Rules.alarms) {
            expect(Rules.byCounting(p, c, a), Rules.byChances(p, c, a), reason: '$p $c $a');
          }
        }
      }
    });

    test('in a hundred, told', () {
      expect(Rules.inHundred((11, 122)), '9.01');
      expect(Rules.inHundred((1, 2)), '50.00');
      expect(Rules.told((99, 100)), 'ninety-nine in a hundred');
      expect(Rules.told((0, 1)), 'none');
      expect(Rules.told((1, 1)), 'every one');
    });
  });

  group('the sweep', () {
    test('225 settings and the counts', () {
      expect(Rules.sweep((p, c, a) => true), (225, 225));
      expect(Rules.sweep(Levels.at(0).meets), (4, 225));
      expect(Rules.sweep(Levels.at(1).meets), (40, 225));
      expect(Rules.sweep(Levels.at(2).meets), (5, 225));
      expect(Rules.sweep(Levels.at(3).meets), (1, 225));
      expect(Rules.sweep(Levels.at(4).meets), (0, 225));
      expect(Rules.sweep((p, c, a) => Rules.byChances(p, c, a) == (1, 1)), (45, 225));
    });

    test('the first settings', () {
      expect(Rules.first(Levels.at(0).meets), (10, (9, 10), (1, 10)));
      expect(Rules.first(Levels.at(1).meets), (100, (9, 10), (1, 10)));
      expect(Rules.first(Levels.at(2).meets), (1000, (9, 10), (0, 1)));
      expect(Rules.first(Levels.at(3).meets), (1000, (999, 1000), (1, 1000)));
      expect(Rules.first(Levels.at(4).meets), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Sure Flag']);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the fever and the test so a flagged villager is ill exactly one time in two');
      expect(Levels.at(2).task, 'set the fever at one in a thousand and the test so a flagged villager is ill at least nine times in ten');
      expect(Levels.at(4).task, 'set the fever and the test so a flagged villager is ill every time while the test still flags some of the well');
    });

    test('an ask is met by the setting it names', () {
      expect(Levels.at(0).meets(100, (99, 100), (1, 100)), isTrue);
      expect(Levels.at(0).meets(100, (99, 100), (1, 1000)), isFalse);
      expect(Levels.at(1).meets(1000, (99, 100), (1, 100)), isTrue);
      expect(Levels.at(2).meets(1000, (9, 10), (0, 1)), isTrue);
      expect(Levels.at(2).meets(1000, (999, 1000), (1, 1000)), isFalse);
      expect(Levels.at(3).meets(1000, (999, 1000), (1, 1000)), isTrue);
      expect(Levels.at(4).meets(100, (1, 1), (0, 1)), isFalse);
    });
  });

  group('the play', () {
    test('opens with the fever one in two and the test nine in ten each way', () {
      final play = Play.of(Levels.at(0));
      expect((play.oneIn, play.catchRate, play.alarm), (2, (9, 10), (1, 10)));
      expect(play.share, (9, 10));
      for (final level in Levels.all) {
        expect(Play.of(level).isDone, isFalse, reason: level.name);
      }
    });

    test('a dial is set, and setting it the same again is nothing', () {
      var play = Play.of(Levels.at(0));
      play = play.set(0, 5);
      expect(play.oneIn, 100);
      expect(play.moves, 1);
      play = play.set(0, 5);
      expect(play.moves, 1);
      play = play.set(1, 2).set(2, 2);
      expect((play.catchRate, play.alarm), ((99, 100), (1, 100)));
      expect(play.moves, 3);
      expect(play.isDone, isTrue);
      expect(play.set(2, 9).alarmAt, 2);
    });

    test('back undoes one setting', () {
      final play = Play.of(Levels.at(0)).set(0, 3);
      expect(play.back.prevalence, 0);
    });

    test('the even chance lands at one in ten from the opening', () {
      final play = Play.of(Levels.at(0)).set(0, 2);
      expect(play.share, (1, 2));
      expect(play.isDone, isTrue);
    });

    test('the sure flag gives up after twenty-four settings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        play = play.set(0, k % 2 == 0 ? 1 : 0);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer names the dial toward the first setting', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (0, 8));
      play = play.set(0, 8);
      expect(play.next, (1, 3));
      play = play.set(1, 3);
      expect(play.next, (2, 3));
      play = play.set(2, 3);
      expect(play.isDone, isTrue);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var taps = 0;
        while (!play.isDone && taps < 12) {
          final (dial, i) = play.next!;
          play = play.set(dial, i);
          taps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
