import 'package:flutter_test/flutter_test.dart';
import 'package:crustleigh/show/levels.dart';
import 'package:crustleigh/show/play.dart';
import 'package:crustleigh/show/rules.dart';

/// The show's law, and the play that judges it, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the majority', () {
    test('a pie beats another when more judges rank it above', () {
      final profile = [[0, 1, 2], [1, 2, 0], [2, 0, 1]];
      expect(Rules.count(profile, 0, 1), 2);
      expect(Rules.beats(profile, 0, 1), isTrue);
      expect(Rules.beats(profile, 1, 2), isTrue);
      expect(Rules.beats(profile, 2, 0), isTrue);
      expect(Rules.beats(profile, 1, 0), isFalse);
    });

    test('the ring, the winner, the firsts and the points', () {
      final ring = [[0, 1, 2], [1, 2, 0], [2, 0, 1]];
      expect(Rules.ring(ring, 3), isTrue);
      expect(Rules.ringOrder(ring, 3), [0, 1, 2]);
      expect(Rules.condorcetWinner(ring, 3), isNull);
      expect(Rules.allRotations(ring), isTrue);
      final straight = [[0, 1, 2], [0, 2, 1], [1, 0, 2]];
      expect(Rules.ring(straight, 3), isFalse);
      expect(Rules.condorcetWinner(straight, 3), 0);
      expect(Rules.firsts(straight), {0, 1});
      expect(Rules.points(straight, 3), [5, 3, 1]);
      expect(Rules.allRotations(straight), isFalse);
    });

    test('rankings are all the orders', () {
      expect(Rules.rankings(3), hasLength(6));
      expect(Rules.rankings(4), hasLength(24));
      expect(Rules.rankings(3).first, [0, 1, 2]);
    });
  });

  group('the sweep', () {
    test('216 shows of three pies, 12 rings, all of them turnings', () {
      expect(Rules.sweep(3, (p) => true), (216, 216));
      expect(Rules.sweep(3, (p) => Rules.ring(p, 3)), (12, 216));
      expect(Rules.sweep(3, Rules.allRotations), (12, 216));
      expect(Rules.sweep(3, (p) => Rules.ring(p, 3) != Rules.allRotations(p)), (0, 216));
      expect(Rules.sweepBags(3, (p) => Rules.ring(p, 3)), (12, 216));
    });

    test('with three pies the winner is always somebody\'s first', () {
      expect(Rules.sweep(3, (p) => Rules.condorcetWinner(p, 3) != null), (204, 216));
      expect(Rules.sweep(3, Levels.at(4).meets), (0, 216));
      expect(Rules.sweepBags(3, Levels.at(4).meets), (0, 216));
    });

    test('the four-pie counts, twice', () {
      for (final level in [Levels.at(1), Levels.at(2), Levels.at(3)]) {
        expect(Rules.sweep(4, level.meets), (level.ways, 13824), reason: level.name);
        expect(Rules.sweepBags(4, level.meets), (level.ways, 13824), reason: level.name);
      }
    });

    test('the first shows', () {
      expect(Rules.first(3, Levels.at(0).meets), [[0, 1, 2], [1, 2, 0], [2, 0, 1]]);
      expect(Rules.first(4, Levels.at(3).meets), [[0, 1, 2, 3], [2, 1, 0, 3], [3, 1, 0, 2]]);
      expect(Rules.first(3, Levels.at(4).meets), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Modest Winner']);
      expect(Levels.at(4).settings, 216);
      expect(Levels.at(1).settings, 13824);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'rank the three pies so the majority runs in a ring, each beating the next and the last the first');
      expect(Levels.at(2).task, 'rank the four pies so one beats every other head to head and another has more points');
      expect(Levels.at(4).task, 'rank the three pies so one beats every other head to head and is first on no ballot');
    });

    test('an ask is met by the show it names', () {
      expect(Levels.at(0).meets([[0, 1, 2], [1, 2, 0], [2, 0, 1]]), isTrue);
      expect(Levels.at(0).meets([[0, 1, 2], [0, 1, 2], [0, 1, 2]]), isFalse);
      expect(Levels.at(3).meets([[0, 1, 2, 3], [2, 1, 0, 3], [3, 1, 0, 2]]), isTrue);
      expect(Levels.at(4).meets([[0, 1, 2], [2, 1, 0], [1, 0, 2]]), isFalse);
      // The points betrayed: damson beats every other two to one, apple
      // outscores it.
      final betrayed = Rules.first(4, Levels.at(2).meets)!;
      final w = Rules.condorcetWinner(betrayed, 4)!;
      final pts = Rules.points(betrayed, 4);
      expect(pts.any((x) => x > pts[w]), isTrue);
    });
  });

  group('the play', () {
    test('opens with every judge ranking the pies alike', () {
      final play = Play.of(Levels.at(0));
      expect(play.profile, [[0, 1, 2], [0, 1, 2], [0, 1, 2]]);
      expect(play.winner, 0);
      expect(play.ringOrder, isNull);
      expect(play.isDone, isFalse);
    });

    test('a tap moves a pie up a place, and the top one round to the bottom', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(1, 2);
      expect(play.profile[1], [0, 2, 1]);
      play = play.tap(1, 2);
      expect(play.profile[1], [2, 0, 1]);
      play = play.tap(1, 2);
      expect(play.profile[1], [0, 1, 2]);
      expect(play.moves, 3);
      expect(play.profile[0], [0, 1, 2]);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(0, 1);
      expect(play.back.profile[0], [0, 1, 2]);
      expect(play.back.back.profile[0], [0, 1, 2]);
    });

    test('the ring lands by hand', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(1, 1).tap(1, 2);
      expect(play.profile[1], [1, 2, 0]);
      play = play.tap(2, 2).tap(2, 2);
      expect(play.profile[2], [2, 0, 1]);
      expect(play.isDone, isTrue);
      expect(play.ringOrder, [0, 1, 2]);
    });

    test('the modest winner gives up after twenty-four taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        play = play.tap(k % 3, 2);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer names the pie to move up toward the sweep\'s first show', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (1, 1));
      play = play.tap(1, 1);
      expect(play.profile[1], [1, 0, 2]);
      expect(play.next, (1, 2));
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var taps = 0;
        while (!play.isDone && taps < 30) {
          final (j, pie) = play.next!;
          play = play.tap(j, pie);
          taps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
