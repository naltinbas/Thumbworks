import 'package:flutter_test/flutter_test.dart';
import 'package:fusewick/fuse/level.dart';
import 'package:fusewick/fuse/levels.dart';
import 'package:fusewick/fuse/play.dart';
import 'package:fusewick/fuse/rules.dart';

/// The law of the fuses, held to.
void main() {
  group('the rules', () {
    test('a fuse burns an hour from one end and half from both', () {
      expect(Rules.nextBurnout([(Rules.hour, 1)]), 240);
      expect(Rules.nextBurnout([(Rules.hour, 2)]), 120);
      expect(Rules.nextBurnout([(Rules.hour, 0)]), isNull);
      expect(Rules.nextBurnout([(120, 2), (Rules.hour, 1)]), 60);
      expect(Rules.burned([(Rules.hour, 1), (Rules.hour, 2)], 120), [(120, 1), (0, 2)]);
    });

    test('minutes read in halves', () {
      expect(Level.minutes(120), '30 minutes');
      expect(Level.minutes(210), '52 and a half minutes');
      expect(Level.minutes(80), '20 minutes');
    });

    test('the sweep finds the times one, two and three fuses strike', () {
      expect(Rules.sweep(1, -1).$1.toList()..sort(), [120, 240]);
      expect(Rules.sweep(2, -1).$1.toList()..sort(), [120, 180, 240, 360, 480]);
      expect(Rules.sweep(3, -1).$1.toList()..sort(), [120, 180, 210, 240, 270, 300, 360, 420, 480, 600, 720]);
      expect(Rules.sweep(2, 80).$2, 0);
      final (_, striking, plans) = Rules.sweep(2, 180);
      expect((striking, plans), (2, 19));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final (_, striking, plans) = Rules.sweep(level.fuses, level.asked);
        expect(striking, level.ways, reason: level.name);
        expect(plans, level.plans, reason: level.name);
      }
    });

    test('the plans found strike their times', () {
      expect(Rules.plan(1, 120), [(0, 0, 2)]);
      expect(Rules.plan(2, 180), [(0, 0, 1), (0, 1, 2), (120, 0, 1)]);
      expect(Rules.plan(2, 80), isNull);
      expect(Rules.plan(3, 210), isNotNull);
    });
  });

  group('the play', () {
    test('opens at nought with fresh fuses', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.now, 0, reason: level.name);
        expect(play.left, everyElement(Rules.hour));
        expect(play.anythingAlight, isFalse);
        expect(play.isDone, isFalse);
      }
    });

    test('an end lights once, the clock burns on, and back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.light(0, false);
      expect(play.lit[0], (true, false));
      expect(play.moves, 1);
      expect(play.light(0, false), same(play));
      expect(play.burn().now, 240);
      play = play.light(1, false).light(1, true);
      expect(play.nextBurnout, 120);
      play = play.burn();
      expect(play.now, 120);
      expect(play.left, [120, 0]);
      expect(play.back.now, 0);
      expect(play.light(1, false), same(play));
    });

    test('the forty-five by hand, and the thirty', () {
      var play = Play.of(Levels.at(1)).light(0, false).light(1, false).light(1, true).burn();
      expect(play.now, 120);
      play = play.light(0, true).burn();
      expect(play.now, 180);
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
      final thirty = Play.of(Levels.at(0)).light(0, false).light(0, true).burn();
      expect(thirty.isDone, isTrue);
      final sixty = Play.of(Levels.at(0)).light(0, false).burn();
      expect(sixty.now, 240);
      expect(sixty.missed, isTrue);
      expect(sixty.gaveUp, isFalse);
    });

    test('the pointer strikes every winnable time', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final n = play.next!;
          play = n.$1 == 'burn' ? play.burn() : play.light(n.$2, n.$3);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the hopeless time is passed by the first burnout', () {
      var play = Play.of(Levels.at(4)).light(0, false).light(0, true).light(1, false).burn();
      expect(play.now, 120);
      expect(play.now > play.level.asked, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.burn(), same(play));
      final slow = Play.of(Levels.at(4)).light(0, false).burn();
      expect(slow.now, 240);
      expect(slow.gaveUp, isTrue);
    });

    test('the mark stands at the half hour', () {
      final mark = Play.standing(Levels.at(1), 120, const [0, 120], const [(true, true), (true, true)]);
      expect(mark.now, 120);
      expect(mark.nextBurnout, 60);
      expect(mark.burn().isDone, isTrue);
    });
  });
}
