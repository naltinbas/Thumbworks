import 'package:flutter_test/flutter_test.dart';
import 'package:haltwick/wait/frac.dart';
import 'package:haltwick/wait/level.dart';
import 'package:haltwick/wait/levels.dart';
import 'package:haltwick/wait/play.dart';
import 'package:haltwick/wait/rules.dart';

/// The waits, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the waits', () {
    test('the timetables, the buses, the wait at a minute and the two averages', () {
      expect(Rules.timetables, hasLength(1711));
      expect(Rules.timetables.first, [1, 1, 58]);
      expect(Rules.timetables.last, [58, 1, 1]);
      expect(Rules.valid([10, 20, 30]), isTrue);
      expect(Rules.valid([0, 30, 30]), isFalse);
      expect(Rules.valid([10, 20, 31]), isFalse);
      expect(Rules.busesAt([10, 20, 30]), [0, 10, 30]);
      expect(Rules.waitAt([10, 20, 30], 0), 0);
      expect(Rules.waitAt([10, 20, 30], 5), 5);
      expect(Rules.waitAt([10, 20, 30], 10), 0);
      expect(Rules.waitAt([10, 20, 30], 59), 1);
      expect(Rules.waitByGaps([10, 20, 30]), Frac.of(67, 6));
      expect(Rules.waitByMinutes([10, 20, 30]), Frac.of(67, 6));
      expect(Rules.waitByGaps([20, 20, 20]), Frac.of(19, 2));
      expect(Rules.waitByGaps([10, 10, 40]), Frac.of(29, 2));
      expect(Rules.waitByGaps([1, 1, 58]), Frac.of(551, 20));
      expect(Rules.fairWait, Frac.of(19, 2));
      expect(Rules.longest([10, 20, 30]), 29);
      expect(Rules.tell(Frac.of(19, 2)), '9 1/2');
      expect(Rules.tell(Frac.of(67, 6)), '11 1/6');
      expect(Rules.tell(Frac.of(10)), '10');
      expect(Rules.tell(Frac.of(1, 2)), '1/2');
      expect(Rules.tellGaps([10, 20, 30]), '10, 20 and 30');
      expect(Level.worst, Frac.of(551, 20));
    });

    test('the sweep: the two averages agree on every timetable, and none is under the fair', () {
      var quarter = 0, halves = 0, worst = 0;
      Frac? least;
      for (final g in Rules.timetables) {
        final w = Rules.waitByGaps(g);
        expect(Rules.waitByMinutes(g), w, reason: '$g');
        expect(w.compareTo(Rules.fairWait) >= 0, isTrue, reason: '$g');
        expect(w.isWhole, isFalse, reason: '$g');
        if (w.compareTo(Frac.of(15)) >= 0) quarter++;
        if (w.d == BigInt.two) halves++;
        if (w == Level.worst) worst++;
        if (least == null || w.compareTo(least) < 0) least = w;
      }
      expect(least, Rules.fairWait);
      expect((quarter, halves, worst), (555, 4, 3));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Short Wait']);
      for (final level in Levels.all) {
        var ways = 0;
        for (final g in Rules.timetables) {
          if (level.meets(g)) ways++;
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [20, 20, 20]);
      expect(Levels.at(1).aim, [10, 10, 40]);
      expect(Levels.at(2).aim, [1, 1, 58]);
      expect(Levels.at(3).aim, [1, 1, 58]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the gaps so that the average wait is the fair 9 1/2 minutes');
      expect(Levels.at(1).task, 'set the gaps so that the average wait is 14 1/2 minutes');
      expect(Levels.at(2).task, 'set the gaps so that the average wait is a quarter hour or more');
      expect(Levels.at(3).task, 'set the gaps so that the average wait is as long as it can be');
      expect(Levels.at(4).task, 'set the gaps so that the average wait is under the fair 9 1/2 minutes');
    });

    test('an ask is met by the timetable', () {
      expect(Levels.at(0).meets([20, 20, 20]), isTrue);
      expect(Levels.at(0).meets([10, 20, 30]), isFalse);
      expect(Levels.at(1).meets([40, 10, 10]), isTrue);
      expect(Levels.at(1).meets([20, 20, 20]), isFalse);
      expect(Levels.at(2).meets([5, 5, 50]), isTrue);
      expect(Levels.at(2).meets([10, 20, 30]), isFalse);
      expect(Levels.at(3).meets([58, 1, 1]), isTrue);
      expect(Levels.at(3).meets([2, 1, 57]), isFalse);
      expect(Levels.at(4).meets([20, 20, 20]), isFalse);
      expect(Levels.at(0).meets([20, 20, 21]), isFalse);
    });
  });

  group('the play', () {
    test('opens at 10, 20 and 30', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.gaps, [10, 20, 30]);
        expect((play.wait, play.moves), (Frac.of(67, 6), 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a step keeps three gaps of a minute or more', () {
      final play = Play.of(Levels.at(0));
      expect(play.step('g1', 1).gaps, [11, 20, 29]);
      expect(play.step('g2', -1).gaps, [10, 19, 31]);
      expect(play.step('g1', 30), same(play));
      expect(Play.standing(Levels.at(0), 1, 1).step('g1', -1).gaps, [1, 1, 58]);
      expect(Play.standing(Levels.at(0), 30, 29).step('g2', 1).gaps, [30, 29, 1]);
      expect(play.step('g1', 1).moves, 1);
    });

    test('back undoes one step', () {
      final play = Play.of(Levels.at(0)).step('g1', 1).step('g1', 1);
      expect(play.back.gaps, [11, 20, 29]);
      expect(play.back.back.gaps, [10, 20, 30]);
    });

    test('the pointer moves the first gap towards the aim, then the second', () {
      expect(Play.of(Levels.at(0)).next, ('g1', 1));
      expect(Play.pointed(('g1', 1)), 'Step the first gap up.');
      expect(Play.of(Levels.at(1)).next, ('g2', -1));
      expect(Play.pointed(('g2', -1)), 'Step the second gap down.');
      expect(Play.of(Levels.at(3)).next, ('g1', -1));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 60) {
          final (which, by) = play.next!;
          play = play.step(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var fair = Play.of(Levels.at(0));
      while (!fair.isDone) {
        final (which, by) = fair.next!;
        fair = fair.step(which, by);
      }
      expect(fair.gaps, [20, 20, 20]);
      expect(fair.moves, 10);
    });

    test('the short wait admits it at the fair timetable, or after twenty-four taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 9; k++) {
        play = play.step('g1', 1);
      }
      expect(play.gaps, [19, 20, 21]);
      expect(play.gaveUp, isFalse);
      play = play.step('g1', 1);
      expect(play.gaps, [20, 20, 20]);
      expect(play.wait, Rules.fairWait);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        wander = wander.step('g2', k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 24);
    });

    test('the why tells Feller and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Feller set the paradox down in 1966'));
      expect(words, contains('1,711'));
      expect(words, contains('This is ask 5, The Short Wait.'));
      expect(words, contains('waited out in full'));
    });
  });
}
